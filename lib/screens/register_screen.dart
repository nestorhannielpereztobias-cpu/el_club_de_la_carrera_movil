import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar texto
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Valores de los desplegables de fecha
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;

  // Valor del Género
  String? _selectedGender;

  // Listas simuladas de fecha (rellena según requieras)
  final List<String> _days = List.generate(31, (index) => (index + 1).toString());
  final List<String> _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];
  final List<String> _years = List.generate(100, (index) => (DateTime.now().year - index).toString());

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0056B3);
    const darkBlue = Color(0xFF003366);

    // Decoración reutilizable para los inputs de texto
    InputDecoration inputDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: primaryBlue),
        ),
      );
    }

    // Decoración para desplegables
    InputDecoration dropdownDecoration() {
      return InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                const Text(
                  'Únete a El Club de la Carrera',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Subtítulo
                const Text(
                  'Crea una cuenta para recibir entrenamientos personalizados de atletismo y registrar tus entrenamientos.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFEDF2F7)),
                const SizedBox(height: 16),

                // Fila Nombre y Apellido
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: inputDecoration('Nombre'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: inputDecoration('Apellido'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sección Fecha de Nacimiento
                const Text(
                  'Fecha de nacimiento',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDay,
                        hint: const Text('Día', style: TextStyle(fontSize: 14)),
                        decoration: dropdownDecoration(),
                        items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                        onChanged: (val) => setState(() => _selectedDay = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        hint: const Text('Mes', style: TextStyle(fontSize: 14)),
                        decoration: dropdownDecoration(),
                        items: _months.map((month) => DropdownMenuItem(value: month, child: Text(month))).toList(),
                        onChanged: (val) => setState(() => _selectedMonth = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedYear,
                        hint: const Text('Año', style: TextStyle(fontSize: 14)),
                        decoration: dropdownDecoration(),
                        items: _years.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                        onChanged: (val) => setState(() => _selectedYear = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sección Género
                const Text(
                  'Género',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Mujer', style: TextStyle(color: Colors.black87)),
                            Radio<String>(
                              value: 'Mujer',
                              groupValue: _selectedGender,
                              activeColor: primaryBlue,
                              onChanged: (val) => setState(() => _selectedGender = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Hombre', style: TextStyle(color: Colors.black87)),
                            Radio<String>(
                              value: 'Hombre',
                              groupValue: _selectedGender,
                              activeColor: primaryBlue,
                              onChanged: (val) => setState(() => _selectedGender = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Campo Correo Electrónico
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration('Correo electrónico'),
                ),
                const SizedBox(height: 16),

                // Campo Contraseña Nueva
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: inputDecoration('Contraseña nueva'),
                ),
                const SizedBox(height: 24),

                // Botón Registrarte
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Guardar / Procesar localmente antes de pasárselo a tu compañero
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Registrarte',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón Ya tengo una cuenta
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Vuelve al Login
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: darkBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: const Text(
                    'Ya tengo una cuenta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}