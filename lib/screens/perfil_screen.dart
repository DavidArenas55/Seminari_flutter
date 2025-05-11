import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Layout.dart';
import '../services/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authService = AuthService();

    try {
      final data = await authService.getCurrentUser();

      if (data == null) {
        context.go('/login');
      } else {
        setState(() {
          user = data;
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al carregar el perfil: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No estàs autenticat')));
    }

    return LayoutWrapper(
      title: 'Perfil',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, size: 70, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  user!['name'] ?? 'Nom desconegut',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user!['email'] ?? 'Email desconegut',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Datos del perfil
                _buildCard([
                  _buildProfileItem(context, Icons.badge, 'ID', user!['_id'] ?? ''),
                  const Divider(),
                  _buildProfileItem(context, Icons.cake, 'Edat', user!['age']?.toString() ?? 'Desconeguda'),
                ]),

                const SizedBox(height: 24),

                // Configuración
                _buildCard([
                  Text('Configuració del compte', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildSettingItem(
                    context,
                    Icons.edit,
                    'Editar Perfil',
                    'Actualitza la teva informació personal',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _buildSettingItem(
                    context,
                    Icons.lock,
                    'Canviar contrasenya',
                    'Actualitza la teva contrasenya',
                    onTap: () => context.push('/profile/password'),
                  ),
                ]),

                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final authService = AuthService();
                      await authService.logout();
                      context.go('/login');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al tancar sessió: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('TANCAR SESSIÓ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
