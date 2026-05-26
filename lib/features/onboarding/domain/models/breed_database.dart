import '../../../pets/domain/entities/pet_entity.dart';

/// Species-specific breed database
class BreedDatabase {
  static const Map<PetSpecies, List<String>> breedMap = {
    PetSpecies.dog: [
      'Golden Retriever', 'Labrador', 'German Shepherd', 'French Bulldog',
      'Bulldog', 'Poodle', 'Beagle', 'Rottweiler', 'Boxer',
      'Dachshund', 'Corgi', 'Siberian Husky', 'Great Dane',
      'Doberman', 'Shih Tzu', 'Yorkshire Terrier', 'Australian Shepherd',
      'Chihuahua', 'Border Collie', 'Mixed Breed', 'Other',
    ],
    PetSpecies.cat: [
      'Persian', 'Maine Coon', 'Siamese', 'British Shorthair',
      'Russian Blue', 'Bengal', 'Ragdoll', 'Abyssinian',
      'Scottish Fold', 'Sphynx', 'American Shorthair',
      'Norwegian Forest', 'Exotic Shorthair', 'Domestic Shorthair',
      'Domestic Longhair', 'Mixed Breed', 'Other',
    ],
    PetSpecies.rabbit: [
      'Holland Lop', 'Netherland Dwarf', 'Mini Rex', 'Lionhead',
      'Rex', 'French Angora', 'English Angora', 'English Spot',
      'Harlequin', 'Holland', 'Mini Satin', 'Flemish Giant',
      'Rex', 'Domestic Rabbit', 'Mixed Breed', 'Other',
    ],
    PetSpecies.bird: [
      'Budgerigar (Parakeet)', 'Cockatiel', 'Cockatoo', 'Conure',
      'Lovebird', 'Canary', 'Finch', 'Parrotlet',
      'Macaw', 'Pionus', 'Quaker', 'Eclectus',
      'African Grey', 'Budgie', 'Other',
    ],
    PetSpecies.fish: [
      'Goldfish', 'Betta', 'Guppy', 'Angelfish',
      'Clownfish', 'Neon Tetra', 'Oscar', 'Discus',
      'Molly', 'Swordtail', 'Corydoras', 'Pleco',
      'Koi', 'Cichlid', 'Other',
    ],
    PetSpecies.hamster: [
      'Syrian', 'Winter White', 'Campbell', 'Roborovski',
      'Chinese', 'Teddy Bear', 'Other',
    ],
    PetSpecies.reptile: [
      'Leopard Gecko', 'Corn Snake', 'Ball Python', 'Bearded Dragon',
      'Blue-Tongued Skink', 'Hermanns Tortoise', 'Red-Eared Slider',
      'Crested Gecko', 'Iguana', 'Chameleon', 'Other',
    ],
    PetSpecies.horse: [
      'Thoroughbred', 'Quarter Horse', 'Arabian', 'Appaloosa',
      'Paint', 'Clydesdale', 'Shetland Pony', 'Palomino',
      'Morgan', 'Standardbred', 'Other',
    ],
  };

  static const Map<PetSpecies, String> emojiMap = {
    PetSpecies.dog: '🐕',
    PetSpecies.cat: '🐈',
    PetSpecies.rabbit: '🐇',
    PetSpecies.bird: '🐦',
    PetSpecies.fish: '🐟',
    PetSpecies.hamster: '🐹',
    PetSpecies.reptile: '🦎',
    PetSpecies.horse: '🐴',
    PetSpecies.other: '🐾',
  };

  static List<String> getBreedsForSpecies(PetSpecies species) {
    return breedMap[species] ?? ['Other'];
  }

  static String speciesEmoji(PetSpecies species) {
    return emojiMap[species] ?? '🐾';
  }
}
