import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InactivateMemberDialog extends StatelessWidget {
  final String memberName;
  final VoidCallback onConfirm;

  const InactivateMemberDialog({
    super.key,
    required this.memberName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Inativar Membro?',
        style: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2C3338),
        ),
      ),
      content: Text(
        'Tem certeza que deseja inativar o registro de $memberName? '
        'Esta ação removerá o acesso dele ao aplicativo, mas o histórico '
        'será mantido na secretaria.',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF596065),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF37628A),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA83836),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Inativar',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
