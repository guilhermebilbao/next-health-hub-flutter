import 'package:flutter/material.dart';
import 'package:next_health_hub/shared/app_formatters.dart';
import 'package:next_health_hub/services/notification_service.dart';

class NextAppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final Future<String>? patientNameFuture;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NextAppDrawer({
    super.key,
    required this.onLogout,
    this.patientNameFuture,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                  child: FutureBuilder<String>(
                    future: patientNameFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final name = snapshot.data ?? 'Usuário';
                      final initials = AppFormatters.getInitials(name);

                      return Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(27, 106, 123, 1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  'Paciente',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(indent: 24, endIndent: 24),
                const SizedBox(height: 10),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  text: 'Dashboard',
                  index: 0,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.folder_copy_outlined,
                  text: 'Meus Exames',
                  index: 1,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.history_edu_outlined,
                  text: 'Histórico de Prontuário',
                  index: 2,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.credit_card_outlined,
                  text: 'Carteirinha Saúde One',
                  index: 3,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.support_agent_outlined,
                  text: 'SAC - Em breve',
                  index: 4,
                  isEnabled: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildDrawerItem(
              context: context,
              icon: Icons.notifications_active_outlined,
              text: 'Testar Notificação',
              index: -2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: _buildDrawerItem(
              context: context,
              icon: Icons.logout,
              text: 'Sair',
              index: -1,
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required int index,
    bool isLogout = false,
    bool isEnabled = true,
  }) {
    final bool isSelected = isEnabled && selectedIndex == index;
    final Color selectedColor = const Color.fromRGBO(27, 106, 123, 1);
    final Color selectedItemColor = Colors.white;
    final Color unselectedItemColor = isEnabled
        ? Colors.black54
        : Colors.black26;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isSelected ? selectedColor : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        enabled: isEnabled,
        leading: Icon(
          icon,
          color: isSelected ? selectedItemColor : unselectedItemColor,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? selectedItemColor : unselectedItemColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: isEnabled
            ? () {
                Navigator.pop(context);
                if (isLogout) {
                  onLogout();
                } else if (index == -2) {
                  NotificationService().showInstantNotification();
                } else {
                  onItemSelected(index);
                }
              }
            : null,
      ),
    );
  }
}
