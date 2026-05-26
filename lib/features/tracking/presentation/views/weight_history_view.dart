import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/weight_log_entity.dart';
import '../../../../core/storage/database_helper.dart';
import '../../../../di/app_module.dart';

/// Weight history view with chart and log entry
///
/// Displays:
/// - Weight chart (line graph via CustomPainter)
/// - Weight statistics (current, min, max, change)
/// - Recent weight logs list
/// - Add weight entry FAB
class WeightHistoryView extends ConsumerStatefulWidget {
  final String petId;
  final String petName;
  const WeightHistoryView({super.key, required this.petId, required this.petName});

  @override
  ConsumerState<WeightHistoryView> createState() => _WeightHistoryViewState();
}

class _WeightHistoryViewState extends ConsumerState<WeightHistoryView> {
  final _weightController = TextEditingController();
  List<WeightLogEntity> _logs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeightLogs();
  }

  Future<void> _loadWeightLogs() async {
    setState(() => _isLoading = true);
    try {
      final dbHelper = getIt<DatabaseHelper>();
      final results = await dbHelper.getWeightLogsByPet(widget.petId);
      setState(() {
        _logs = results.map((r) {
          return WeightLogEntity(
            id: r['id'] as String,
            petId: r['petId'] as String,
            weight: (r['weight'] as num).toDouble(),
            unit: r['unit'] as String? ?? 'kg',
            loggedAt: DateTime.tryParse(r['date'] as String) ?? DateTime.now(),
            createdAt: DateTime.now(),
          );
        }).toList()
          ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _addWeightLog() async {
    if (_weightController.text.isEmpty) return;
    final weight = double.tryParse(_weightController.text);
    if (weight == null) return;

    try {
      final dbHelper = getIt<DatabaseHelper>();
      final log = {
        'id': const Uuid().v4(),
        'petId': widget.petId,
        'weight': weight,
        'date': DateTime.now().toIso8601String(),
        'unit': 'kg',
      };
      await dbHelper.insertWeightLog(log);
      _weightController.text = '';
      await _loadWeightLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight logged!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteLog(String id) async {
    try {
      final dbHelper = getIt<DatabaseHelper>();
      await dbHelper.deleteWeightLog(id);
      await _loadWeightLogs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Statistics
  double get _currentWeight => _logs.isNotEmpty ? _logs.last.weight : 0;
  double get _minWeight => _logs.isNotEmpty ? _logs.map((l) => l.weight).reduce((a, b) => a < b ? a : b) : 0;
  double get _maxWeight => _logs.isNotEmpty ? _logs.map((l) => l.weight).reduce((a, b) => a > b ? a : b) : 0;
  double get _weightChange => _logs.length >= 2 ? _logs.last.weight - _logs[_logs.length - 2].weight : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.petName} — Weight'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : CustomScrollView(
                  slivers: [
                    // Statistics cards
                    SliverToBoxAdapter(
                      child: _buildStatsCards(),
                    ),
                    // Chart
                    SliverToBoxAdapter(
                      child: _buildChart(),
                    ),
                    // Add weight input
                    SliverToBoxAdapter(
                      child: _buildWeightInput(),
                    ),
                    // Weight log list
                    _buildWeightLogList(),
                  ],
                ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Current',
                  value: '${_currentWeight > 0 ? _currentWeight.toStringAsFixed(1) : '--'} kg',
                  icon: Icons.monitor_weight,
                  color: PawTableColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Min',
                  value: '${_minWeight > 0 ? _minWeight.toStringAsFixed(1) : '--'} kg',
                  icon: Icons.trending_down,
                  color: PawTableColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Max',
                  value: '${_maxWeight > 0 ? _maxWeight.toStringAsFixed(1) : '--'} kg',
                  icon: Icons.trending_up,
                  color: PawTableColors.warning,
                ),
              ),
            ],
          ),
          if (_logs.length >= 2) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _weightChange >= 0
                    ? PawTableColors.error.withValues(alpha: 0.08)
                    : PawTableColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _weightChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: _weightChange >= 0 ? PawTableColors.error : PawTableColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Changed ${_weightChange.abs().toStringAsFixed(1)} kg since last entry',
                    style: TextStyle(
                      color: _weightChange >= 0 ? PawTableColors.error : PawTableColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_logs.length < 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Add more weight entries to see the trend',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: CustomPaint(
          size: Size(double.infinity, 200),
          painter: WeightChartPainter(logs: _logs),
        ),
      ),
    );
  }

  Widget _buildWeightInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _weightController,
              decoration: InputDecoration(
                hintText: 'Enter weight in kg',
                prefixIcon: const Icon(Icons.monitor_weight, color: PawTableColors.primary),
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _addWeightLog,
            style: ElevatedButton.styleFrom(
              backgroundColor: PawTableColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLogList() {
    final reversedLogs = _logs.reversed.toList();
    if (reversedLogs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final log = reversedLogs[index];
          final diff = _computeDiff(reversedLogs, index);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: CircleAvatar(
                backgroundColor: PawTableColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.monitor_weight, color: PawTableColors.primary),
              ),
              title: Text(
                '${log.weight.toStringAsFixed(1)} kg',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy • h:mm a').format(log.loggedAt),
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (diff != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: diff >= 0 ? PawTableColors.error : PawTableColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _deleteLog(log.id),
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: reversedLogs.length,
      ),
    );
  }

  double? _computeDiff(List<WeightLogEntity> logs, int index) {
    if (index >= logs.length - 1) return null;
    return logs[index].weight - logs[index + 1].weight;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple line chart for weight history using CustomPainter
class WeightChartPainter extends CustomPainter {
  final List<WeightLogEntity> logs;

  WeightChartPainter({required this.logs});

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.length < 2) return;

    final padding = EdgeInsets.all(20);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    final weights = logs.map((l) => l.weight).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = maxW - minW == 0 ? 1 : maxW - minW;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = padding.top + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );
      // Y-axis labels
      final value = maxW - (range / 4) * i;
      final textPainter = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(1),
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // Data points and lines
    final points = <Offset>[];
    for (int i = 0; i < logs.length; i++) {
      final x = padding.left + (i / (logs.length - 1)) * chartWidth;
      final y = padding.top + chartHeight - ((logs[i].weight - minW) / range) * chartHeight;
      points.add(Offset(x, y));
    }

    // Fill area
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height - padding.bottom);
    for (final p in points) fillPath.lineTo(p.dx, p.dy);
    fillPath.lineTo(points.last.dx, size.height - padding.bottom);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          PawTableColors.primary.withValues(alpha: 0.3),
          PawTableColors.primary.withValues(alpha: 0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = PawTableColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // Points
    for (int i = 0; i < points.length; i++) {
      // Dot
      canvas.drawCircle(
        points[i],
        5,
        Paint()
          ..color = PawTableColors.primary
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        points[i],
        3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      // X-axis labels (dates)
      final textPainter = TextPainter(
        text: TextSpan(
          text: _formatDateShort(logs[i].loggedAt),
          style: TextStyle(fontSize: 9, color: Colors.grey[600]),
        ),
        
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, size.height - padding.bottom + 4),
      );
    }
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
