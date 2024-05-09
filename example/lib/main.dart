import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlutoGrid Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlutoGridExamplePage(),
    );
  }
}

/// PlutoGrid Example
//
/// For more examples, go to the demo web link on the github below.
class PlutoGridExamplePage extends StatefulWidget {
  const PlutoGridExamplePage({super.key});

  @override
  State<PlutoGridExamplePage> createState() => _PlutoGridExamplePageState();
}

class _PlutoGridExamplePageState extends State<PlutoGridExamplePage> {
  late final List<PlutoColumn> columns;

  final List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'id': PlutoCell(value: 'user1'),
        'name': PlutoCell(value: 'Mike'),
        'age': PlutoCell(value: 20),
        'role': PlutoCell(value: 'Programmer'),
        'role2': PlutoCell(value: 'Programmer'),
        'joined': PlutoCell(value: '2021-01-01'),
        'working_time': PlutoCell(value: '09:00'),
        'salary': PlutoCell(value: 300),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: 'user2'),
        'name': PlutoCell(value: 'Jack'),
        'age': PlutoCell(value: 25),
        'role': PlutoCell(value: 'Designer'),
        'role2': PlutoCell(value: 'Designer'),
        'joined': PlutoCell(value: '2021-02-01'),
        'working_time': PlutoCell(value: '10:00'),
        'salary': PlutoCell(value: 400),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: 'user3'),
        'name': PlutoCell(value: 'Suzi'),
        'age': PlutoCell(value: 40),
        'role': PlutoCell(value: 'Owner'),
        'role2': PlutoCell(value: 'Owner'),
        'joined': PlutoCell(value: '2021-03-01'),
        'working_time': PlutoCell(value: '11:00'),
        'salary': PlutoCell(value: 700),
      },
    ),
  ];

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: true),
    PlutoColumnGroup(title: 'User information', fields: ['name', 'age']),
    PlutoColumnGroup(title: 'Status', children: [
      PlutoColumnGroup(title: 'A', fields: ['role'], expandedColumn: true),
      PlutoColumnGroup(
          title: 'Etc.', fields: ['joined', 'working_time', 'role2']),
    ]),
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    columns = [
      PlutoColumn(
        title: 'Id',
        field: 'id',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Age',
        field: 'age',
        type: PlutoColumnType.number(),
        colorRender: (context) => _render(context),
        renderer: (context) {
          print('CALLED');
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  color: Colors.purple,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    context.cell.value.toString(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'Role',
        field: 'role',
        type: PlutoColumnType.select(<String>[
          'Programmer',
          'Designer',
          'Owner',
        ]),
      ),
      PlutoColumn(
        title: 'Role 2',
        field: 'role2',
        type: PlutoColumnType.select(
          <String>[
            'Programmer',
            'Designer',
            'Owner',
          ],
          builder: (item) {
            return Row(children: [
              Icon(item == 'Programmer' ? Icons.code : Icons.design_services),
              const SizedBox(width: 8),
              Text(item),
            ]);
          },
        ),
      ),
      PlutoColumn(
        title: 'Joined',
        field: 'joined',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Working time',
        field: 'working_time',
        type: PlutoColumnType.time(),
      ),
      PlutoColumn(
        title: 'salary',
        field: 'salary',
        type: PlutoColumnType.currency(),
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            formatAsCurrency: true,
            type: PlutoAggregateColumnType.sum,
            format: '#,###',
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Sum',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(text: ' : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
    ];
  }

  Color _render(PlutoColumnCellColorRendererContext context) {
    final color = switch (context.cell.value) {
      >= 20 && < 25 => Colors.red,
      >= 25 && < 40 => Colors.yellow,
      >= 40 && < 50 => Colors.blue,
      >= 50 => Colors.green,
      _ => Colors.grey
    };

    return context.isCurrentCell || context.isSelectedCell
        ? color.withOpacity(0.5)
        : color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          columnGroups: columnGroups,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager.setSelectingMode(PlutoGridSelectingMode.cell);
            stateManager.setShowColumnFilter(false);
            stateManager.setShowColumnTitle(false);
            stateManager.setShowColumnFooter(false);
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          configuration: const PlutoGridConfiguration(
            columnSize: PlutoGridColumnSizeConfig(
              autoSizeMode: PlutoAutoSizeMode.none,
            ),
            style: PlutoGridStyleConfig(
              activatedColor: Colors.transparent,
              cellColorInEditState: Colors.transparent,
              enableGridBorderShadow: true,
              defaultCellPadding: EdgeInsets.zero,
              defaultColumnTitlePadding: EdgeInsets.zero,
              defaultColumnFilterPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}
