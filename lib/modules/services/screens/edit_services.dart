import 'package:snapservice/common.dart';

class EditServicesPage extends ConsumerStatefulWidget {
  const EditServicesPage({super.key});

  @override
  ConsumerState<EditServicesPage> createState() => _EditServicesPageState();
}

class _EditServicesPageState extends ConsumerState<EditServicesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeServicesProvider);
    final businessServices = ref.watch(businessServicesProvider);
    final allitems = businessServices.services;

    final double width = MediaQuery.of(context).size.width;
    bool isSmallScreen = width < 600;
    return Scaffold(
      backgroundColor: theme.secondaryBackGround,
      appBar:
          isSmallScreen
              ? AppBar(
                backgroundColor: theme.secondaryBackGround,
                foregroundColor: theme.textIconPrimaryColor,
                centerTitle: true,
                title: const Text('Edit Services'),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(28.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicator: UnderlineTabIndicator(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.textIconPrimaryColor,
                          width: 2,
                        ),
                      ),
                      indicatorWeight: 1,
                      labelColor: theme.textIconPrimaryColor,
                      unselectedLabelColor: theme.textIconSecondaryColor,
                      tabs: const [Text('Services'), Text('Addons')],
                    ),
                  ),
                ),
              )
              : null,
      body: Column(
        children: [
          if (!isSmallScreen) const Header(title: 'Edit Items'),
          if (!isSmallScreen)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: UnderlineTabIndicator(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.textIconPrimaryColor,
                    width: 2,
                  ),
                ),
                indicatorWeight: 1,
                labelColor: theme.textIconPrimaryColor,
                unselectedLabelColor: theme.textIconSecondaryColor,
                tabs: const [Text('Services'), Text('Addons')],
              ),
            ),
          Expanded(
            child: SizedBox(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _items(
                    allitems
                        .where((x) => x.type.toLowerCase() == 'main')
                        .toList(),
                  ),
                  _items(
                    allitems
                        .where((x) => x.type.toLowerCase() == 'addon')
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _floatingBtn(),
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
              'Add Service',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              EditSavisPage.show(context).then((value) {
                if (value == '200') {
                  context.showToast(
                    'Service added',
                    textColor: theme.textIconPrimaryColor,
                  );
                  ref.invalidate(businessServicesProvider);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _items(List<Savis> items) {
    final theme = ref.watch(themeServicesProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int crossAxisCount =
            width > 1200
                ? 5
                : width > 800
                ? 4
                : width > 600
                ? 3
                : 2;

        double aspectRatio = width < 400 ? 0.8 / 1.4 : 0.8 / 1.1;

        return Center(
          child: GridView.builder(
            padding: const EdgeInsets.only(left: 16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final savis = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SavisCard(
                  savis: savis,
                  width: 100,
                  onEdit: () {
                    EditSavisPage.show(context, savis).then((value) {
                      if (value == '200') {
                        context.showToast(
                          'Updated successfully',
                          textColor: theme.textIconPrimaryColor,
                        );
                        ref.invalidate(businessServicesProvider);
                      }
                    });
                  },
                  showAddButton: false,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
