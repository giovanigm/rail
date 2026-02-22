import 'package:flutter/widgets.dart';
import 'package:rail/rail.dart';

import 'counter/counter_page.dart';
import 'counter/counter_page_rail.dart';
import 'login/login_page.dart';
import 'login/login_page_rail.dart';

typedef Example = ({String name, Widget widget});

final examples = <Example>[
  (
    name: "Counter",
    widget: RailProvider<CounterPageRail>(
      create: (_) => CounterPageRail(),
      child: const CounterPage(),
    )
  ),
  (
    name: "Login",
    widget: RailProvider<LoginPageRail>(
      create: (_) => LoginPageRail(),
      child: const LoginPage(),
    ),
  )
];
