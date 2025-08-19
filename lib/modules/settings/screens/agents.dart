import 'package:snapservice/common.dart';

class AgentsPage extends ConsumerStatefulWidget {
  const AgentsPage({super.key});

  @override
  ConsumerState<AgentsPage> createState() => _AgentsPageState();
}

class _AgentsPageState extends ConsumerState<AgentsPage> {
  String selectedType = 'ALL';
  String selectedStatus = 'ALL';
  String sortOption = 'A-Z';
  bool ascending = true;

  final List<String> types = ['ALL', 'SuperAdmin', 'FrontOffice', 'Employee'];
  final List<String> statuses = ['ALL', 'ACTIVE', 'INACTIVE'];
  final List<String> sortOptions = ['A-Z', 'Z-A'];

  @override
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final agentsState = ref.watch(agentsServicesProvider);
    final branches = ref.watch(branchesServicesProvider).value;
    final settings = ref.watch(settingsServicesProvider);
    final userService = ref.watch(authenticationServiceProvider);
    final user = userService.valueOrNull?.user;

    final showFAB =
        (settings.createAttendant && user?.type == FRONTOFFICE_TYPE_NAME) ||
        (user?.type == SUPERADMIN_TYPE_NAME);

    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackGround,
        foregroundColor: theme.textIconPrimaryColor,
        centerTitle: true,
        title: const Text('Agents'),
        actions: [
          TextButton.icon(
            onPressed: () {
              showSearch(
                context: context,
                useRootNavigator: false,
                delegate: AgentsSearch(
                  agents: agentsState.value ?? [],
                  updateAgent: (updatedAgent) {
                    setState(() {
                      final index = agentsState.value?.indexWhere(
                        (agent) => agent.id == updatedAgent.id,
                      );
                      if (index != null && index >= 0) {
                        agentsState.value?[index] = updatedAgent;
                      }
                    });
                  },
                ),
              );
            },
            icon: Icon(Icons.search_rounded, color: theme.textIconPrimaryColor),
            label: Text(
              'Search',
              style: TextStyle(color: theme.textIconPrimaryColor),
            ),
          ),
        ],
      ),
      body: agentsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Text(
                'Error: $error',
                style: TextStyle(color: theme.textIconPrimaryColor),
              ),
            ),
        data:
            (agents) =>
                _buildAgentsList(agents, branches, settings, user, theme),
      ),
      floatingActionButtonLocation:
          showFAB ? FloatingActionButtonLocation.endFloat : null,
      floatingActionButton: showFAB ? _floatingBtn() : null,
    );
  }

  Widget _buildAgentsList(
    List<Agent> agents,
    List<Map<dynamic, dynamic>>? branches,
    settings,
    user,
    ThemeConfig theme,
  ) {
    List<Agent> filtered = _filteredAgents(agents);
    return Column(
      children: [
        _buildFilters(theme),
        Expanded(
          child:
              filtered.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 60,
                          color: theme.inactiveBackGround,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No agents available',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.inactiveBackGround,
                          ),
                        ),
                      ],
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(agentsServicesProvider);
                    },
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder:
                          (context, index) =>
                              _agentCard(filtered[index], branches, theme),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildFilters(theme) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDropdown(
                label: 'Type',
                value: selectedType,
                items: types,
                onChanged: (value) => setState(() => selectedType = value!),
                theme: theme,
              ),
              _buildDropdown(
                label: 'Status',
                value: selectedStatus,
                items: statuses,
                onChanged: (value) => setState(() => selectedStatus = value!),
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDropdown(
                label: 'Sort By',
                value: sortOption,
                items: sortOptions,
                onChanged: (value) => setState(() => sortOption = value!),
                theme: theme,
              ),
              IconButton(
                icon: Icon(
                  ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: theme.textIconPrimaryColor,
                ),
                onPressed: () {
                  setState(() {
                    ascending = !ascending;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Agent> _filteredAgents(List<Agent> agents) {
    List<Agent> filtered = agents;
    if (selectedType != 'ALL') {
      filtered = filtered.where((agent) => agent.type == selectedType).toList();
    }
    if (selectedStatus != 'ALL') {
      filtered =
          filtered.where((agent) {
            return selectedStatus == 'ACTIVE'
                ? !agent.archived
                : agent.archived;
          }).toList();
    }

    filtered.sort((a, b) {
      int comparison =
          sortOption == 'A-Z'
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name);
      return ascending ? comparison : -comparison;
    });

    return filtered;
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeConfig theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.textIconPrimaryColor,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButton<String>(
          value: value,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(color: theme.textIconPrimaryColor),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          dropdownColor: theme.secondaryBackGround,
          focusColor: theme.secondaryBackGround,
          iconEnabledColor: theme.textIconPrimaryColor,
        ),
      ],
    );
  }

  Widget _agentCard(
    Agent agent,
    List<Map<dynamic, dynamic>>? branches,
    ThemeConfig theme,
  ) {
    return Card(
      color: theme.primaryBackGround,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.cardGradientStart, theme.cardGradientEnd],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.cardShadowColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundColor: theme.activeBackGround,
            child: Text(
              agent.name.trim().isNotEmpty ? agent.name.trim()[0] : 'N',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.activeTextIconColor,
              ),
            ),
          ),
          title: Text(
            agent.name.trim(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.activeTextIconColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agent.email,
                style: TextStyle(
                  color: theme.activeTextIconColor,
                  fontSize: 14,
                ),
              ),
              Text(
                'Phone: ${agent.phone}',
                style: TextStyle(
                  color: theme.activeTextIconColor,
                  fontSize: 14,
                ),
              ),
              Text(
                'ID: ${agent.userID}',
                style: TextStyle(
                  color: theme.activeTextIconColor,
                  fontSize: 14,
                ),
              ),
              if (agent.store != null)
                Text(
                  'Store: ${agent.store}',
                  style: TextStyle(
                    color: theme.activeTextIconColor,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'PIN: ${agent.pin}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.activeTextIconColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    agent.archived ? 'Inactive' : 'Active',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          agent.archived
                              ? theme.deleteColor
                              : theme.successColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit, color: theme.activeTextIconColor),
            onPressed: () {
              EditAgent.show(context, agent, branches);
            },
          ),
        ),
      ),
    );
  }

  Widget _floatingBtn() {
    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(themeServicesProvider);
        return Container(
          margin: const EdgeInsets.only(bottom: 30, right: 5),
          child: FloatingActionButton.extended(
            backgroundColor: theme.primaryBackGround,
            foregroundColor: theme.activeTextIconColor,
            elevation: 6,
            icon: const Icon(Icons.add, size: 24),
            label: Text(
              'Add Agent',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              EditAgent.show(context).then((value) {
                if (value == '200') {
                  ref.invalidate(agentsServicesProvider);
                }
              });
            },
          ),
        );
      },
    );
  }
}

class AgentsSearch extends SearchDelegate {
  final List<Agent> agents;
  final Function(Agent) updateAgent;
  final List<Map<dynamic, dynamic>>? branches;
  AgentsSearch({
    required this.agents,
    required this.updateAgent,
    this.branches,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final theme = container.read(themeServicesProvider);
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: theme.secondaryBackGround,
      appBarTheme: AppBarTheme(
        backgroundColor: theme.secondaryBackGround,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textIconPrimaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.secondaryBackGround,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: theme.textIconSecondaryColor),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: theme.textIconPrimaryColor),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  Widget _buildResults() {
    final results =
        agents
            .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => _agentCard(results[index], context),
    );
  }

  Widget _agentCard(Agent agent, BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final theme = container.read(themeServicesProvider);
    return Card(
      color: theme.primaryBackGround,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: theme.activeBackGround,
          child: Text(
            agent.name.trim().isNotEmpty ? agent.name.trim()[0] : 'N',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.activeTextIconColor,
            ),
          ),
        ),
        title: Text(
          agent.name.trim(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.activeTextIconColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agent.email,
              style: TextStyle(color: theme.activeTextIconColor, fontSize: 14),
            ),
            Text(
              'Phone: ${agent.phone}',
              style: TextStyle(color: theme.activeTextIconColor, fontSize: 14),
            ),
            Text(
              'ID: ${agent.userID}',
              style: TextStyle(color: theme.activeTextIconColor, fontSize: 14),
            ),
            if (agent.store != null)
              Text(
                'Store: ${agent.store}',
                style: TextStyle(
                  color: theme.activeTextIconColor,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'PIN: ${agent.pin}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.activeTextIconColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  agent.archived ? 'Inactive' : 'Active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        agent.archived ? theme.deleteColor : theme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: theme.activeTextIconColor),
          onPressed: () {
            EditAgent.show(context, agent, branches);
          },
        ),
      ),
    );
  }
}

class EditAgent extends StatefulWidget {
  const EditAgent({this.agent, super.key, this.loadedShops});
  final Agent? agent;
  final List<Map<dynamic, dynamic>>? loadedShops;

  static Future<String?> show(
    BuildContext context, [
    Agent? agent,
    List<Map<dynamic, dynamic>>? loadedShops,
  ]) {
    return showDialog<String>(
      useRootNavigator: false,
      context: context,
      builder: (_) {
        return EditAgent(agent: agent, loadedShops: loadedShops);
      },
    );
  }

  @override
  State<EditAgent> createState() => _EditAgentState();
}

class _EditAgentState extends State<EditAgent> {
  bool isupdating = false;
  final GlobalKey<FormState> _form = GlobalKey();
  late final TextEditingController _cName = TextEditingController(
    text: widget.agent?.name,
  );
  late final TextEditingController _cEmail = TextEditingController(
    text: widget.agent?.email,
  );
  late final TextEditingController _cPhone = TextEditingController(
    text: widget.agent?.phone,
  );
  late final TextEditingController _cId = TextEditingController(
    text: widget.agent?.userID.toString(),
  );
  late final TextEditingController _cPin = TextEditingController(
    text: widget.agent?.pin.toString(),
  );
  late final TextEditingController _cCommission = TextEditingController(
    text: widget.agent?.commission.toString(),
  );

  late final TextEditingController _cType = TextEditingController(
    text: widget.agent?.type,
  );

  late final TextEditingController _cShop = TextEditingController(
    text: () {
      final ls = widget.agent?.store;
      final b =
          widget.loadedShops
              ?.where((element) => element['name'] == ls)
              .firstOrNull;
      if (b != null) {
        shopId = b['id'];
        return b['name'];
      }
    }(),
  );
  late num? shopId = widget.agent?.shop;
  late bool archived = widget.agent?.archived ?? false;

  @override
  Widget build(BuildContext context) {
    final dWidth = context.sz.width;
    final width = dWidth > 400.0 ? 400.0 : dWidth;
    return Center(
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer(
            builder: (context, ref, _) {
              final theme = ref.watch(themeServicesProvider);
              final branchesService = ref.watch(branchesServicesProvider);
              return Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: theme.activeTextIconColor,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Form(
                          key: _form,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _cName,
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true) ? '' : null,
                                style: TextStyle(color: theme.defultColor),
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                    color: theme.defultColor,
                                  ),
                                  filled: true,
                                  fillColor: theme.activeTextIconColor,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _cEmail,
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true) ? '' : null,
                                style: TextStyle(color: theme.defultColor),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: theme.defultColor,
                                  ),
                                  filled: true,
                                  fillColor: theme.activeTextIconColor,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _cPhone,
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true) ? '' : null,
                                style: TextStyle(color: theme.defultColor),
                                decoration: InputDecoration(
                                  labelText: 'Phone number',
                                  labelStyle: TextStyle(
                                    color: theme.defultColor,
                                  ),
                                  filled: true,
                                  fillColor: theme.activeTextIconColor,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _cPin,
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true) ? '' : null,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(color: theme.defultColor),
                                decoration: InputDecoration(
                                  labelText: 'Pin',
                                  labelStyle: TextStyle(
                                    color: theme.defultColor,
                                  ),
                                  filled: true,
                                  fillColor: theme.activeTextIconColor,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _cId,
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true) ? '' : null,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(color: theme.defultColor),
                                decoration: InputDecoration(
                                  labelText: 'National ID',
                                  labelStyle: TextStyle(
                                    color: theme.defultColor,
                                  ),
                                  filled: true,
                                  fillColor: theme.activeTextIconColor,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                ),
                              ),
                              branchesService.when(
                                loading:
                                    () => const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Shop',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        LinearProgressIndicator(),
                                      ],
                                    ),
                                error:
                                    (error, stackTrace) => Text(
                                      'Unable to load shops',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: theme.deleteColor,
                                      ),
                                    ),
                                data: (data) {
                                  return TextFormField(
                                    controller: _cShop,
                                    readOnly: true,
                                    validator:
                                        (value) =>
                                            (value?.isEmpty ?? true)
                                                ? ''
                                                : null,
                                    onTap: () {
                                      SelectShop.show(context, data).then((
                                        value,
                                      ) {
                                        if (value != null) {
                                          shopId = value['id'];
                                          _cShop.text = value['name'];
                                        }
                                      });
                                    },
                                    style: TextStyle(color: theme.defultColor),
                                    decoration: InputDecoration(
                                      suffixIcon: Icon(Icons.arrow_drop_down),
                                      labelText: 'Shop',
                                      labelStyle: TextStyle(
                                        color: theme.defultColor,
                                      ),
                                      filled: true,
                                      fillColor: theme.activeTextIconColor,
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: theme.defultColor,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: theme.defultColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              TextFormField(
                                controller: _cCommission,
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true) ? '' : null,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(color: theme.defultColor),
                                decoration: InputDecoration(
                                  labelText: 'Commission',
                                  labelStyle: TextStyle(
                                    color: theme.defultColor,
                                  ),
                                  filled: true,
                                  fillColor: theme.activeTextIconColor,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _cType,
                                readOnly: true,
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true) ? '' : null,
                                onTap: () {
                                  showUserTypes(context).then((value) {
                                    if (value != null) {
                                      _cType.text = value;
                                    }
                                  });
                                },
                                style: TextStyle(color: theme.defultColor),
                                decoration: InputDecoration(
                                  labelText: 'User level',
                                  labelStyle: TextStyle(
                                    color: theme.defultColor,
                                  ),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                  filled: true,
                                  fillColor: theme.activeTextIconColor,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.defultColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                title: Text(
                                  'Agent Archived',
                                  style: TextStyle(color: theme.defultColor),
                                ),
                                contentPadding: EdgeInsets.zero,
                                value: archived,
                                onChanged: (value) {
                                  setState(() {
                                    archived = value;
                                  });
                                },
                                activeColor: theme.activeTextIconColor,
                                activeTrackColor: theme.successColor,
                                inactiveThumbColor: theme.activeTextIconColor,
                                inactiveTrackColor: theme.primaryBackGround,
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: .5,
                        thickness: .5,
                        color: theme.inactiveBackGround,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextButton(
                          onPressed:
                              isupdating
                                  ? null
                                  : () {
                                    if (_form.currentState!.validate()) {
                                      setState(() {
                                        isupdating = true;
                                      });
                                      _update(ref);
                                    }
                                  },
                          style: TextButton.styleFrom(
                            backgroundColor: theme.primaryBackGround,
                            foregroundColor: theme.activeTextIconColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            fixedSize: const Size(double.maxFinite, 20),
                          ),
                          child:
                              isupdating
                                  ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: theme.activeTextIconColor,
                                    ),
                                  )
                                  : Text(
                                    widget.agent == null ? 'ADD' : 'UPDATE',
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _update(WidgetRef ref) {
    final theme = ref.watch(themeServicesProvider);
    final newAgent = Agent(
      id: widget.agent?.id ?? 0,
      name: _cName.text,
      email: _cEmail.text,
      phone: _cPhone.text,
      archived: archived,
      pin: num.tryParse(_cPin.text) ?? 0,
      commission: num.tryParse(_cCommission.text) ?? 0,
      shop: shopId ?? 0,
      userID: num.tryParse(_cId.text) ?? 0,
      type: _cType.text,
      store: _cShop.text,
    );

    if (widget.agent != null) {
      ref
          .read(agentsServicesProvider.notifier)
          .update(agent: newAgent, shop: _cShop.text)
          .then((value) {
            context.pop();
            ref.invalidate(agentsServicesProvider);
            context.showToast(
              'Agent updated',
              textColor: theme.textIconPrimaryColor,
            );
          })
          .onError((error, stackTrace) {
            setState(() {
              isupdating = false;
            });
          });
    } else {
      ref
          .read(agentsServicesProvider.notifier)
          .add(agent: newAgent, shop: _cShop.text)
          .then((value) {
            context.pop();
            ref.invalidate(agentsServicesProvider);
            context.showToast(
              'Agent updated',
              textColor: theme.textIconPrimaryColor,
            );
          })
          .onError((error, stackTrace) {
            setState(() {
              isupdating = false;
            });
          });
    }
  }

  Future<String?> showUserTypes(BuildContext context) {
    final levels = ['Employee', 'FrontOffice', 'SuperAdmin'];
    return showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(levels.length, (index) {
                    final level = levels[index];
                    return InkWell(
                      onTap: () {
                        context.pop(level);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(level),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
