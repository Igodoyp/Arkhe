import 'package:flutter/material.dart';
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/stat_type.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap; // Función que se ejecuta al tocar

  const MissionCard({super.key, required this.mission, required this.onTap});

  // Función auxiliar para elegir color según el Stat (UX Visual)
  Color _getColorForStat(StatType stat) {
    switch (stat) {
      case StatType.strength: return Colors.redAccent;
      case StatType.intelligence: return Colors.blueAccent;
      case StatType.charisma: return Colors.yellowAccent;
      case StatType.vitality: return Colors.green;
      case StatType.dexterity: return Colors.orange;
      case StatType.wisdom: return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForStat(mission.type);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4, // Sombra para dar efecto de "item flotante"
      child: ListTile(
        // ICONO DEL STAT A LA IZQUIERDA
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.flash_on, color: color), // Podrías cambiar el icono según stat
        ),
        
        // TÍTULO Y DESCRIPCIÓN
        title: Text(
          mission.title,
          style: TextStyle(
            decoration: mission.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mission.description),
            SizedBox(height: 5),
            // CHIPS DE RECOMPENSA (GAMIFICACIÓN)
            Row(
              children: [
                _RewardChip(label: "+${mission.xpReward} XP", color: Colors.grey),
                SizedBox(width: 5),
                _RewardChip(label: "+ ${mission.type.name}", color: color),
              ],
            )
          ],
        ),
        
        // CHECKBOX A LA DERECHA
        trailing: Checkbox(
          value: mission.isCompleted,
          activeColor: color, // El checkbox toma el color del stat
          onChanged: (val) => onTap(),
        ),
      ),
    );
  }
}

// Un widget privado pequeño para las etiquetas de "XP" y "Stat"
class _RewardChip extends StatelessWidget {
  final String label;
  final Color color;

  const _RewardChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}