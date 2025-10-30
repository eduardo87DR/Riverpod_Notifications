import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const destinos = [
    {'nombre': 'Cancún', 'tipo': 'Playa'},
    {'nombre': 'Tulum', 'tipo': 'Zona arqueológica'},
    {'nombre': 'Bacalar', 'tipo': 'Laguna'},
    {'nombre': 'Isla Mujeres', 'tipo': 'Isla'},
  ];

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    // Obtener token FCM del dispositivo
    final token = await FirebaseMessaging.instance.getToken();
    setState(() => _token = token);

    // Suscribirse al tópico "ofertas"
    await FirebaseMessaging.instance.subscribeToTopic('ofertas');
    debugPrint('📲 Suscrito al tópico "ofertas"');
    debugPrint('🔑 Token FCM: $_token');
  }

  @override
  Widget build(BuildContext context) {
    final badge = ref.watch(badgeCountProvider);
    final service = ref.read(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Destinos ($badge)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notificación local',
            onPressed: () async {
              await service.showLocal(
                title: 'Novedad turística',
                body: 'Nueva promo en Quintana Roo 🌴',
                payload: '/promo',
              );
              ref.read(badgeCountProvider.notifier).state++;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Token visual
          Padding(
            padding: const EdgeInsets.all(12.0),
          ),
          const Divider(),
          // Lista de destinos
          Expanded(
            child: ListView.separated(
              itemCount: HomePage.destinos.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (_, i) {
                final d = HomePage.destinos[i];
                return ListTile(
                  leading: const Icon(Icons.place),
                  title: Text(d['nombre']!),
                  subtitle: Text(d['tipo']!),
                  onTap: () async {
                    await service.showLocal(
                      title: 'Explora ${d['nombre']}',
                      body: 'Descubre ${d['nombre']} (${d['tipo']})',
                      payload: '/destino/${d['nombre']}',
                    );
                    ref.read(badgeCountProvider.notifier).state++;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
