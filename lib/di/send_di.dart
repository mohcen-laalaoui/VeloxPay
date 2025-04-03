import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:VeloxPay/UI/views/dashboard/send.dart';
import 'package:VeloxPay/repositories/send_repository.dart';
import 'package:VeloxPay/viewmodels/send_viewmodel.dart';

class SendModule {
  static Widget provideSendPage({VoidCallback? onTransactionComplete}) {
    return MultiProvider(
      providers: [
        Provider<SendRepository>(create: (_) => SendRepository()),
        ChangeNotifierProxyProvider<SendRepository, SendViewModel>(
          create:
              (context) => SendViewModel(
                Provider.of<SendRepository>(context, listen: false),
              ),
          update:
              (context, repository, viewModel) =>
                  viewModel ?? SendViewModel(repository),
        ),
      ],
      child: SendPage(onTransactionComplete: onTransactionComplete),
    );
  }
}
