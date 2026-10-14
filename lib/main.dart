import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _green = Color(0xFF245B48);
const _ink = Color(0xFF1E2924);
const _muted = Color(0xFF738078);
const _canvas = Color(0xFFF5F7F4);
const _line = Color(0xFFE3E9E4);
const _orange = Color(0xFFB75927);

void main() => runApp(const WarehouseApp());

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.dmSansTextTheme();
    return MaterialApp(
      title: 'Lagerbestand',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _green,
          surface: Colors.white,
        ),
        textTheme: textTheme.apply(bodyColor: _ink, displayColor: _ink),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _green, width: 1.5),
          ),
        ),
      ),
      home: const WarehouseHome(),
    );
  }
}

class WarehouseHome extends StatefulWidget {
  const WarehouseHome({super.key});

  @override
  State<WarehouseHome> createState() => _WarehouseHomeState();
}

class _WarehouseHomeState extends State<WarehouseHome> {
  final _searchController = TextEditingController();
  List<InventoryItem> _items = List.of(_demoItems);
  String _searchTerm = '';
  bool _lowStockOnly = false;
  _AppSection _section = _AppSection.overview;
  String? _activeCategory;
  String? _activeProject;

  List<InventoryItem> get _visibleItems => _items.where((item) {
        final matchesSearch =
            '${item.name} ${item.sku} ${item.location} ${item.category}'
                .toLowerCase()
                .contains(_searchTerm.toLowerCase());
        return matchesSearch && (!_lowStockOnly || item.isLowStock);
      }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isCompact = constraints.maxWidth < 600;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop)
                  _DesktopSidebar(
                    section: _section,
                    activeCategory: _activeCategory,
                    activeProject: _activeProject,
                    onOverview: _showOverview,
                    onCategories: _showCategories,
                    onCategory: _showCategory,
                    onProjects: _showProjects,
                    onProject: _showProject,
                    onTools: _showTools,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(
                        isCompact: isCompact,
                        controller: _searchController,
                        onSearchChanged: (value) =>
                            setState(() => _searchTerm = value),
                      ),
                      Expanded(
                        child: _buildPage(
                          isCompact: isCompact,
                          isDesktop: isDesktop,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  height: 68,
                  selectedIndex: _section.index,
                  onDestinationSelected: (index) {
                    setState(() {
                      _section = _AppSection.values[index];
                      _activeCategory = null;
                      _activeProject = null;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'Übersicht',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.category_outlined),
                      selectedIcon: Icon(Icons.category),
                      label: 'Kategorien',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.folder_outlined),
                      selectedIcon: Icon(Icons.folder),
                      label: 'Projekte',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.handyman_outlined),
                      selectedIcon: Icon(Icons.handyman),
                      label: 'Tools',
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showOverview() => setState(() {
        _section = _AppSection.overview;
        _activeCategory = null;
        _activeProject = null;
      });

  void _showCategories() => setState(() {
        _section = _AppSection.categories;
        _activeCategory = null;
        _activeProject = null;
      });

  void _showCategory(String category) => setState(() {
        _section = _AppSection.categories;
        _activeCategory = category;
        _activeProject = null;
      });

  void _showProjects() => setState(() {
        _section = _AppSection.projects;
        _activeCategory = null;
        _activeProject = null;
      });

  void _showProject(String project) => setState(() {
        _section = _AppSection.projects;
        _activeProject = project;
        _activeCategory = null;
      });

  void _showTools() => setState(() {
        _section = _AppSection.tools;
        _activeCategory = null;
        _activeProject = null;
      });

  Widget _buildPage({
    required bool isCompact,
    required bool isDesktop,
  }) => switch (_section) {
        _AppSection.overview => _buildOverview(isCompact, isDesktop),
        _AppSection.categories => _buildCategories(isCompact, isDesktop),
        _AppSection.projects => _buildProjects(isCompact, isDesktop),
        _AppSection.tools => _buildTools(isCompact),
      };

  Widget _buildOverview(bool isCompact, bool isDesktop) {
    final items = _visibleItems;
    return _pageScroll(
      isCompact,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeading(isCompact: isCompact, onAdd: _addItem),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final columns = constraints.maxWidth < 620 ? 2 : 4;
              final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  _Metric(width: width, label: 'Artikel im Bestand', value: '${_items.length}', icon: Icons.inventory_2_outlined, tone: _green),
                  _Metric(width: width, label: 'Niedriger Bestand', value: '${_items.where((item) => item.isLowStock).length}', icon: Icons.warning_amber_rounded, tone: _orange),
                  _Metric(width: width, label: 'Einheiten gesamt', value: '${_items.fold<int>(0, (sum, item) => sum + item.quantity)}', icon: Icons.stacked_bar_chart, tone: const Color(0xFF55768C)),
                  _Metric(width: width, label: 'Standorte', value: '${_items.map((item) => item.location).toSet().length}', icon: Icons.place_outlined, tone: const Color(0xFF8A6A37)),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              avatar: const Icon(Icons.warning_amber_rounded, size: 17),
              label: const Text('Niedriger Bestand'),
              selected: _lowStockOnly,
              onSelected: (value) => setState(() => _lowStockOnly = value),
              showCheckmark: false,
            ),
          ),
          const SizedBox(height: 12),
          _inventoryContent(items, isDesktop),
        ],
      ),
    );
  }

  Widget _buildCategories(bool isCompact, bool isDesktop) {
    final categories = _warehouseCategories.where((category) {
      final categoryItems = _visibleItems.where((item) => item.category == category);
      return _searchTerm.isEmpty ||
          category.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          categoryItems.isNotEmpty;
    }).toList();
    final selected = _activeCategory;
    final categoryItems = selected == null
        ? const <InventoryItem>[]
        : _visibleItems.where((item) => item.category == selected).toList();

    return _pageScroll(
      isCompact,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: selected ?? 'Kategorien',
            subtitle: selected == null
                ? 'Artikel nach Baugruppen und Lagerbereichen ordnen.'
                : '${categoryItems.length} Artikel in dieser Kategorie',
            onBack: selected == null ? null : _showCategories,
          ),
          const SizedBox(height: 20),
          if (selected == null)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final category in categories)
                  _CategoryCard(
                    title: category,
                    count: _items.where((item) => item.category == category).length,
                    onTap: () => _showCategory(category),
                  ),
              ],
            )
          else
            _inventoryContent(categoryItems, isDesktop),
        ],
      ),
    );
  }

  Widget _buildProjects(bool isCompact, bool isDesktop) {
    final selected = _activeProject;
    final projects = _warehouseProjects.where((project) {
      final projectItems = _visibleItems.where((item) => project.skus.contains(item.sku));
      return _searchTerm.isEmpty ||
          project.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          projectItems.isNotEmpty;
    }).toList();
    _WarehouseProject? project;
    if (selected != null) {
      for (final candidate in _warehouseProjects) {
        if (candidate.name == selected) project = candidate;
      }
    }
    final projectItems = _visibleItems
      .where((item) => project?.skus.contains(item.sku) ?? false)
      .toList();

    return _pageScroll(
      isCompact,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: selected ?? 'Projekte',
            subtitle: project == null
                ? 'Zusammengehörige Teile und Baugruppen verwalten.'
                : '${projectItems.length} zugeordnete Teile',
            onBack: selected == null ? null : _showProjects,
          ),
          const SizedBox(height: 20),
          if (selected == null)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in projects)
                  _ProjectCard(
                    project: item,
                    partCount: item.skus.length,
                    onTap: () => _showProject(item.name),
                  ),
              ],
            )
          else
            _inventoryContent(projectItems, isDesktop),
        ],
      ),
    );
  }

  Widget _buildTools(bool isCompact) {
    final tools = _warehouseTools.where((tool) =>
        '${tool.title} ${tool.description}'.toLowerCase().contains(_searchTerm.toLowerCase()));
    return _pageScroll(
      isCompact,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            title: 'Werkzeuge',
            subtitle: 'Hilfen für Erfassung, Import und Bauteilpflege.',
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1000 ? 2 : 3);
              const gap = 12.0;
              final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final tool in tools)
                    _ToolCard(
                      tool: tool,
                      width: width,
                      onTap: () => _showTool(tool),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _pageScroll(bool isCompact, Widget child) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(isCompact ? 18 : 30, 26, isCompact ? 18 : 30, 30),
        child: child,
      );

  Widget _inventoryContent(List<InventoryItem> items, bool isDesktop) {
    if (items.isEmpty) return const _EmptyInventory();
    return isDesktop
        ? _InventoryTable(items: items, onItemTap: _showItemDetails)
        : _InventoryList(items: items, onItemTap: _showItemDetails);
  }

  Future<void> _addItem() async {
    final item = await showDialog<InventoryItem>(
      context: context,
      builder: (context) => const _AddItemDialog(),
    );
    if (item != null && mounted) {
      setState(() => _items = [item, ..._items]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} wurde hinzugefügt')),
      );
    }
  }

  void _showItemDetails(InventoryItem item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailLine(label: 'Artikelnummer', value: item.sku),
            _DetailLine(label: 'Standort', value: item.location),
            _DetailLine(label: 'Menge', value: '${item.quantity} Stück'),
            _DetailLine(label: 'Mindestbestand', value: '${item.minimum} Stück'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  void _showTool(_WarehouseTool tool) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(tool.icon, color: _green),
        title: Text(tool.title),
        content: Text(tool.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isCompact,
    required this.controller,
    required this.onSearchChanged,
  });

  final bool isCompact;
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 72 : 82,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1EC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: _green, size: 20),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 12),
            Text(
              'Warehouse',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 24),
          ] else
            const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: isCompact
                    ? 'Suche in Lager und Projekten'
                    : 'Artikel, Kategorien und Projekte durchsuchen',
                prefixIcon: const Icon(Icons.search, size: 21),
                suffixIcon: isCompact
                    ? null
                    : const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.tune, size: 18, color: _muted),
                      ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 42, minHeight: 42),
              ),
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 14),
            const Tooltip(
              message: 'Lokale Demo-Daten',
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFFE8EFEA),
                child: Text(
                  'W',
                  style: TextStyle(
                    color: _green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.section,
    required this.activeCategory,
    required this.activeProject,
    required this.onOverview,
    required this.onCategories,
    required this.onCategory,
    required this.onProjects,
    required this.onProject,
    required this.onTools,
  });

  final _AppSection section;
  final String? activeCategory;
  final String? activeProject;
  final VoidCallback onOverview;
  final VoidCallback onCategories;
  final ValueChanged<String> onCategory;
  final VoidCallback onProjects;
  final ValueChanged<String> onProject;
  final VoidCallback onTools;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      color: const Color(0xFF1E3028),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 16, 22),
            child: Row(
              children: [
                Icon(Icons.grid_view_rounded, color: Color(0xFFA8D1B2)),
                SizedBox(width: 10),
                Text(
                  'BREMERGY INVENTORY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                _SidebarEntry(
                  icon: Icons.dashboard_outlined,
                  label: 'Übersicht',
                  selected: section == _AppSection.overview,
                  onTap: onOverview,
                ),
                const _SidebarLabel('KATEGORIEN'),
                _SidebarEntry(
                  icon: Icons.category_outlined,
                  label: 'Alle Kategorien',
                  selected: section == _AppSection.categories && activeCategory == null,
                  onTap: onCategories,
                ),
                for (final category in _warehouseCategories)
                  _SidebarEntry(
                    icon: Icons.folder_open_outlined,
                    label: category,
                    selected: section == _AppSection.categories && activeCategory == category,
                    count: _demoItems.where((item) => item.category == category).length,
                    inset: true,
                    onTap: () => onCategory(category),
                  ),
                const _SidebarLabel('PROJEKTE'),
                _SidebarEntry(
                  icon: Icons.folder_outlined,
                  label: 'Alle Projekte',
                  selected: section == _AppSection.projects && activeProject == null,
                  onTap: onProjects,
                ),
                for (final project in _warehouseProjects)
                  _SidebarEntry(
                    icon: Icons.work_outline,
                    label: project.name,
                    selected: section == _AppSection.projects && activeProject == project.name,
                    inset: true,
                    onTap: () => onProject(project.name),
                  ),
                const _SidebarLabel('TOOLS'),
                _SidebarEntry(
                  icon: Icons.handyman_outlined,
                  label: 'Werkzeuge & Verwaltung',
                  selected: section == _AppSection.tools,
                  onTap: onTools,
                ),
              ],
            ),
          ),
          const Spacer(),
          const Divider(color: Color(0xFF3C4D43), height: 1),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.storage_outlined, color: Color(0xFFB6C5BB), size: 17),
                SizedBox(width: 9),
                Text(
                  'PartDB nicht verbunden',
                  style: TextStyle(color: Color(0xFFB6C5BB), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarLabel extends StatelessWidget {
  const _SidebarLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 12, 7),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF91A397),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      );
}

class _SidebarEntry extends StatelessWidget {
  const _SidebarEntry({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.inset = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final bool inset;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(inset ? 22 : 8, 1, 8, 1),
        child: Material(
          color: selected ? const Color(0xFF345243) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 42,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(
                    icon,
                    size: 17,
                    color: selected ? Colors.white : const Color(0xFFB6C5BB),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFFCFD8D1),
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (count != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 9),
                      child: Text(
                        '$count',
                        style: const TextStyle(color: Color(0xFF91A397), fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null) ...[
            IconButton(
              tooltip: 'Zurück',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: _muted, fontSize: 13)),
              ],
            ),
          ),
        ],
      );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.title, required this.count, required this.onTap});

  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 250,
        child: _NavigationCard(
          icon: Icons.folder_open_outlined,
          title: title,
          subtitle: '$count Artikel',
          onTap: onTap,
        ),
      );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project, required this.partCount, required this.onTap});

  final _WarehouseProject project;
  final int partCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 270,
        child: _NavigationCard(
          icon: Icons.folder_outlined,
          title: project.name,
          subtitle: '${project.description} · $partCount Teile',
          onTap: onTap,
        ),
      );
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1EC),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(icon, color: _green, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _muted),
              ],
            ),
          ),
        ),
      );
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.tool,
    required this.width,
    required this.onTap,
  });

  final _WarehouseTool tool;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: _NavigationCard(
          icon: tool.icon,
          title: tool.title,
          subtitle: tool.description,
          onTap: onTap,
        ),
      );
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.isCompact, required this.onAdd});

  final bool isCompact;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: isCompact ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment:
          isCompact ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: isCompact ? 0 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lagerbestand',
                style: TextStyle(
                  fontSize: isCompact ? 24 : 29,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Artikel und Mengen an einem Ort verwalten.',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ],
          ),
        ),
        SizedBox(height: isCompact ? 16 : 0, width: isCompact ? 0 : 16),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 19),
          label: const Text('Artikel hinzufügen'),
          style: FilledButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            minimumSize: Size(isCompact ? double.infinity : 190, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: tone),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({required this.items, required this.onItemTap});

  final List<InventoryItem> items;
  final ValueChanged<InventoryItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          const _TableRow(
            name: 'ARTIKEL',
            sku: 'ARTIKELNUMMER',
            location: 'STANDORT',
            quantity: 'MENGE',
            header: true,
          ),
          for (final item in items)
            _TableRow(
              name: item.name,
              sku: item.sku,
              location: item.location,
              quantity: '${item.quantity} Stk.',
              lowStock: item.isLowStock,
              onTap: () => onItemTap(item),
            ),
        ],
      ),
              initialValue: _category,
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.name,
    required this.sku,
    required this.location,
    required this.quantity,
    this.header = false,
    this.lowStock = false,
    this.onTap,
  });

  final String name;
  final String sku;
  final String location;
  final String quantity;
  final bool header;
  final bool lowStock;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = header ? _muted : _ink;
    final style = TextStyle(
      color: color,
      fontSize: header ? 10 : 13,
      fontWeight: header ? FontWeight.w700 : FontWeight.w500,
      letterSpacing: header ? 0.5 : 0,
    );
    return Material(
      color: header ? const Color(0xFFFAFBFA) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _line)),
          ),
          child: Row(
            children: [
              Expanded(flex: 4, child: Text(name, style: style)),
              Expanded(flex: 2, child: Text(sku, style: style)),
              Expanded(flex: 2, child: Text(location, style: style)),
              SizedBox(
                width: 90,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: header
                      ? Text(quantity, style: style)
                      : Text(
                          quantity,
                          style: style.copyWith(
                            color: lowStock ? _orange : _ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryList extends StatelessWidget {
  const _InventoryList({required this.items, required this.onItemTap});

  final List<InventoryItem> items;
  final ValueChanged<InventoryItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _InventoryListTile(
              item: items[index],
              onTap: () => onItemTap(items[index]),
            ),
            if (index < items.length - 1)
              const Divider(height: 1, color: _line),
          ],
        ],
      ),
    );
  }
}

class _InventoryListTile extends StatelessWidget {
  const _InventoryListTile({required this.item, required this.onTap});

  final InventoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: _green, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.sku}  ·  ${item.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.quantity}',
                  style: TextStyle(
                    color: item.isLowStock ? _orange : _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text('Stück', style: TextStyle(color: _muted, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, color: _muted, size: 25),
          SizedBox(height: 10),
          Text('Keine passenden Artikel gefunden', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  String _category = _warehouseCategories.first;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final sku = _skuController.text.trim();
    final location = _locationController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim());
    if (name.isEmpty || sku.isEmpty || location.isEmpty || quantity == null) {
      setState(() => _error = 'Bitte alle Felder ausfüllen und eine gültige Menge eingeben.');
      return;
    }
    Navigator.pop(
      context,
      InventoryItem(
        name: name,
        sku: sku,
        location: location,
        quantity: quantity,
        minimum: 1,
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Artikel hinzufügen'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Artikelname'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _skuController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Artikelnummer'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Standort'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Kategorie'),
              items: [
                for (final category in _warehouseCategories)
                  DropdownMenuItem(value: category, child: Text(category)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Menge'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: const TextStyle(color: _orange, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Hinzufügen')),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: _muted))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class InventoryItem {
  const InventoryItem({
    required this.name,
    required this.sku,
    required this.location,
    required this.quantity,
    required this.minimum,
    this.category = 'Import',
  });

  final String name;
  final String sku;
  final String location;
  final int quantity;
  final int minimum;
  final String category;

  bool get isLowStock => quantity <= minimum;
}

const _demoItems = [
  InventoryItem(
    name: 'USB-C Netzteil 65 W',
    sku: 'PWR-065-USB',
    location: 'A-01-03',
    quantity: 42,
    minimum: 10,
    category: 'Not PCB Components',
  ),
  InventoryItem(
    name: 'Ethernet-Kabel Cat 6, 2 m',
    sku: 'CBL-C6-002',
    location: 'A-02-01',
    quantity: 8,
    minimum: 12,
    category: 'Not PCB Components',
  ),
  InventoryItem(
    name: 'M.2 SSD 1 TB',
    sku: 'SSD-M2-1TB',
    location: 'B-04-02',
    quantity: 17,
    minimum: 5,
    category: 'PCB Components',
  ),
  InventoryItem(
    name: 'USB-C Dockingstation',
    sku: 'DOCK-USBC-04',
    location: 'B-01-05',
    quantity: 4,
    minimum: 6,
    category: 'Not PCB Components',
  ),
  InventoryItem(
    name: 'Wireless Barcode-Scanner',
    sku: 'SCAN-WL-02',
    location: 'C-01-01',
    quantity: 11,
    minimum: 4,
    category: 'Import',
  ),
];

enum _AppSection { overview, categories, projects, tools }

const _warehouseCategories = [
  'Not PCB Components',
  'PCB Components',
  'X Old Stock',
  'Import',
];

class _WarehouseProject {
  const _WarehouseProject({
    required this.name,
    required this.description,
    required this.skus,
  });

  final String name;
  final String description;
  final List<String> skus;
}

const _warehouseProjects = [
  _WarehouseProject(
    name: 'BreMo24',
    description: 'Steuerplatine',
    skus: ['PWR-065-USB', 'CBL-C6-002'],
  ),
  _WarehouseProject(
    name: 'BreMo25',
    description: 'Anschluss und Versorgung',
    skus: ['PWR-065-USB', 'DOCK-USBC-04', 'SCAN-WL-02'],
  ),
  _WarehouseProject(
    name: 'BreMo26',
    description: 'Speicher-Upgrade',
    skus: ['SSD-M2-1TB', 'CBL-C6-002'],
  ),
  _WarehouseProject(
    name: 'BreMo27',
    description: 'Werkstatt-Ausstattung',
    skus: ['SCAN-WL-02', 'DOCK-USBC-04'],
  ),
  _WarehouseProject(
    name: 'BreMo28',
    description: 'Prototyp',
    skus: ['SSD-M2-1TB', 'PWR-065-USB'],
  ),
  _WarehouseProject(
    name: 'BreMo29',
    description: 'Ersatzteil-Kit',
    skus: ['CBL-C6-002', 'SSD-M2-1TB'],
  ),
];

class _WarehouseTool {
  const _WarehouseTool({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

const _warehouseTools = [
  _WarehouseTool(
    title: 'Etikettengenerator',
    description: 'Etiketten für ausgewählte Artikel vorbereiten.',
    icon: Icons.local_offer_outlined,
  ),
  _WarehouseTool(
    title: 'Scanner',
    description: 'Artikel mit der Kamera oder einem Barcode-Scanner erfassen.',
    icon: Icons.qr_code_scanner,
  ),
  _WarehouseTool(
    title: 'SMD-Rollenrechner',
    description: 'Bauteilmenge und Restbestand einer SMD-Rolle berechnen.',
    icon: Icons.calculate_outlined,
  ),
  _WarehouseTool(
    title: 'Footprint-Bildgalerie',
    description: 'Gehäuseformen und Footprint-Bilder durchsuchen.',
    icon: Icons.image_search_outlined,
  ),
  _WarehouseTool(
    title: 'IC-Logos',
    description: 'Herstellerlogos auf integrierten Schaltungen zuordnen.',
    icon: Icons.memory_outlined,
  ),
  _WarehouseTool(
    title: 'Bulk-Import',
    description: 'Mehrere Teile gesammelt importieren und prüfen.',
    icon: Icons.playlist_add,
  ),
  _WarehouseTool(
    title: 'Teile aus Datenquellen',
    description: 'Bauteildaten aus externen Quellen übernehmen.',
    icon: Icons.cloud_download_outlined,
  ),
  _WarehouseTool(
    title: 'Lieferanten',
    description: 'Lieferantenstammdaten verwalten.',
    icon: Icons.local_shipping_outlined,
  ),
  _WarehouseTool(
    title: 'Hersteller',
    description: 'Herstellerstammdaten verwalten.',
    icon: Icons.factory_outlined,
  ),
  _WarehouseTool(
    title: 'Lagerorte',
    description: 'Regale, Fächer und weitere Lagerorte pflegen.',
    icon: Icons.location_on_outlined,
  ),
  _WarehouseTool(
    title: 'Anhänge und Footprints',
    description: 'Dateien, Datenblätter und Footprints verwalten.',
    icon: Icons.attach_file,
  ),
  _WarehouseTool(
    title: 'Einheiten und Währungen',
    description: 'Mess- und Preisangaben zentral konfigurieren.',
    icon: Icons.tune,
  ),
];