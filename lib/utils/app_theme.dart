import 'package:flutter/material.dart';

/// Define o tema principal do app
class AppTheme {
  // Cor principal do logo
  static const Color _logoBlue = Color(0xFF3B7DC2);
  // Cor secundária (um tom mais escuro)
  static const Color _logoDarkBlue = Color(0xFF2C5A9A);

  static ThemeData get light {
    // Gera um esquema de cores baseado na cor do logo
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _logoBlue,
      brightness: Brightness.light,
      primary: _logoBlue,
      onPrimary: Colors.white,
      secondary: _logoDarkBlue,
      onSecondary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,

      // Aplica nosso colorScheme
      colorScheme: colorScheme,

      // AppBar em azul forte com texto branco e altura reduzida
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 48, // ajuste aqui a altura que preferir
      ),

      // Fundo geral mais claro
      scaffoldBackgroundColor: Colors.grey[50],

      // Tipografia padrão
      typography: Typography.material2021(platform: TargetPlatform.android),
      textTheme:
          Typography.material2021(platform: TargetPlatform.android).black,

      // Cartões com cantos arredondados e sombra
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Botões elevados com cor do logo
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Botões outlined (caso use) com borda azul escuro
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.secondary, width: 2),
          foregroundColor: colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Campos de texto com destaque de cor
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.blue.shade50,
        hintStyle: TextStyle(color: Colors.blueGrey.shade700),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        labelStyle: TextStyle(color: colorScheme.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _logoBlue.withOpacity(0.7), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _logoBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),

      // Cursor e seleção de texto em azul
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: _logoBlue,
        selectionColor: _logoBlue.withOpacity(0.4),
        selectionHandleColor: _logoBlue,
      ),
    );
  }
}

/// Exemplo de cartão customizado para exibir um grupo
class GroupCard extends StatelessWidget {
  final String name;
  final String leader;
  final int volunteersCount;
  final VoidCallback onCalendar;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GroupCard({
    Key? key,
    required this.name,
    required this.leader,
    required this.volunteersCount,
    required this.onCalendar,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: ExpansionTile(
        title: Text(name, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text('Líder: $leader'),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Voluntários: $volunteersCount'),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: colors.primary),
                    onPressed: onCalendar,
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: colors.secondary),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
