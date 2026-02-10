import 'package:cert_exam_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cert_exam_app/widgets/app_drawer.dart';
import 'package:cert_exam_app/models/exam_attempt.dart';
import 'package:cert_exam_app/services/api_service.dart';
import 'package:cert_exam_app/screens/certification_list_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Certification Exam',
          theme: ThemeData(primarySwatch: Colors.blue),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          home: LoginScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<ExamAttempt>>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _historyFuture = ApiService.fetchExamHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: FutureBuilder<List<ExamAttempt>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data ?? [];
          final totalExams = history.length;
          final finishedExams = history.where((e) => e.score != null).toList();
          final avgScore = finishedExams.isEmpty
              ? 0
              : (finishedExams.map((e) => e.score!).reduce((a, b) => a + b) /
                      finishedExams.length)
                  .round();

          return ListView(
            // Changed from SingleChildScrollView to ListView to support RefreshIndicator better
            padding: const EdgeInsets.all(16.0),
            children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _StatCard(
                      title: 'Exams Taken',
                      value: totalExams.toString(),
                      icon: Icons.assignment_turned_in,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      title: 'Avg Score',
                      value: '$avgScore%',
                      icon: Icons.score,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start New Exam'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CertificationListScreen()),
                      );
                      _loadData(); // Refresh stats when returning from exam
                    },
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (history.isEmpty)
                  const Text('No exams taken yet.',
                      style: TextStyle(color: Colors.grey))
                else
                  ...history.take(3).map((attempt) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            attempt.score != null
                                ? Icons.check_circle
                                : Icons.pending,
                            color: attempt.score != null
                                ? Colors.green
                                : Colors.grey,
                          ),
                          title: Text(attempt.certificationName),
                          subtitle: Text(attempt.startedAt
                              .toLocal()
                              .toString()
                              .split('.')[0]),
                          trailing: Text(
                            attempt.score != null
                                ? '${attempt.score}%'
                                : 'In Progress',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
              ],
          );
        },
      ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
