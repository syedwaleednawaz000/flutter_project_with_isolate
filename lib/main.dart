import 'package:flutter/material.dart';
import 'package:isolate_project/provider.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApiProvider(),
      child: const MaterialApp(
        title: 'Flutter Isolate Example',
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Isolate Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer<ApiProvider>(
              builder: (context, apiProvider, child) {
              return             ElevatedButton(
                onPressed: () {
                  if(apiProvider.timerValue == 0){
                    // Start the timer when the button is pressed
                    context.read<ApiProvider>().startTimer();
                  }else{
                    // Start the timer when the button is pressed
                    context.read<ApiProvider>().stopTimer();
                  }
                },
                child: Text('Start Timer'),
              );
            },),
            Consumer<ApiProvider>(
              builder: (context, apiProvider, child) {
                if (apiProvider.timerValue == null) {
                  return const Text('Press the button to start the timer.');
                } else {
                  return Text('Timer Value: ${apiProvider.timerValue}');
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ApiProvider>().fetchData();
              },
              child: Text('Fetch Data'),
            ),
            Consumer<ApiProvider>(
              builder: (context, apiProvider, child) {
                if (apiProvider.apiResponse.isEmpty) {
                  return const Text('Press the button to fetch data.');
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: apiProvider.apiResponse.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(apiProvider.apiResponse[index]),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

