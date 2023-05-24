// import 'dart:math';

// class Timetable {
//   final List<List<String>> slots;

//   Timetable(this.slots);

//   factory Timetable.generate(List<String> subjects, List<int> durations) {
//     var slots = List.generate(
//       durations.length,
//       (_) => List.generate(subjects.length, (_) => ''),
//     );

//     var population = List.generate(
//       100,
//       (_) => Timetable(slots),
//     );
//     Random random = Random();
//     while (true) {
//       // Evaluate the fitness of each timetable.
//       var fitnesses = population.map((timetable) => timetable.fitness).toList();

//       // Select the fittest timetables to be parents.
//       var parents = fitnesses.where((fitness) => fitness > 0.5).toList();

//       // Breed the parents to create new timetables.
//       var children = parents.expand((parent1) {
//         var parent2 = parents[random.nextInt(parents.length)];

//         var slots1 = parent1.slots.map((slot) => slot.toList()).toList();
//         var slots2 = parent2.slots.map((slot) => slot.toList()).toList();

//         var child1 = Timetable(slots);
//         var child2 = Timetable(slots);

//         for (var i = 0; i < slots1.length; i++) {
//           for (var j = 0; j < slots2.length; j++) {
//             if (slots1[i].isEmpty && slots2[j].isEmpty) {
//               slots1[i] = slots2[j];
//               slots2[j] = '';
//             }
//           }
//         }

//         return [child1, child2];
//       }).toList();

//       // Replace the old population with the new population.
//       population = children;

//       // If the fitness of the population has not improved for a certain number of generations, then stop.
//       if (fitnesses.last == fitnesses.first) {
//         break;
//       }
//     }

//     return population.first;
//   }

//   double get fitness {
//     var conflicts = 0;

//     for (var i = 0; i < slots.length; i++) {
//       for (var j = i + 1; j < slots.length; j++) {
//         if (slots[i] == slots[j]) {
//           conflicts++;
//         }
//       }
//     }

//     return 1 - conflicts / slots.length / slots[0].length;
//   }
// }
