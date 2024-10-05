import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../history/payment_history.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            curve: Curves.easeInOut,
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 40,
                  child: Icon(
                    Icons.account_balance_outlined,
                    size: 60,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 10),
                Text(authService.user?.email ?? '',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
          // Lista de elementos del menú
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: 3,
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 1,
                  thickness: 1,
                );
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildListTile(
                    context,
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  );
                } else if (index == 1) {
                  return _buildListTile(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Todos los recibos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentHistory(),
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Cerrar sesión al final del Drawer
          _buildListTile(
            context,
            icon: Icons.logout_outlined,
            title: 'Cerrar sesión',
            color: Colors.redAccent,
            onTap: () {
              authService.signOut();
              Navigator.pop(context);
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  // Método para crear un ListTile personalizado con animación
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: color ?? Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
    );
  }
}
