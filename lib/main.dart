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

  List<InventoryItem> get _visibleItems => _items.where((item) {
        final matchesSearch =
            '${item.name} ${item.sku} ${item.location}'
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
                if (isDesktop) const _DesktopSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(isCompact: isCompact),
                      Expanded(
                        child: _buildInventoryContent(
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
        );
      },
    );
  }

  Widget _buildInventoryContent({
    required bool isCompact,
    required bool isDesktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = isCompact ? 18.0 : 32.0;
        final metricWidth = isCompact
            ? (constraints.maxWidth - horizontalPadding * 2 - 12) / 2
            : (constraints.maxWidth - horizontalPadding * 2 - 36) / 4;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isCompact ? 22 : 30,
            horizontalPadding,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PageHeading(
                isCompact: isCompact,
                onAdd: _addItem,
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Metric(
                    width: metricWidth,
                    label: 'Artikel im Bestand',
                    value: '${_items.length}',
                    icon: Icons.inventory_2_outlined,
                    tone: _green,
                  ),
                  _Metric(
                    width: metricWidth,
                    label: 'Niedriger Bestand',
                    value: '${_items.where((item) => item.isLowStock).length}',
                    icon: Icons.warning_amber_rounded,
                    tone: _orange,
                  ),
                  _Metric(
                    width: metricWidth,
                    label: 'Einheiten gesamt',
                    value: '${_items.fold<int>(0, (sum, item) => sum + item.quantity)}',
                    icon: Icons.stacked_bar_chart,
                    tone: const Color(0xFF55768C),
                  ),
                  _Metric(
                    width: metricWidth,
                    label: 'Standorte',
                    value: '${_items.map((item) => item.location).toSet().length}',
                    icon: Icons.place_outlined,
                    tone: const Color(0xFF8A6A37),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _InventoryToolbar(
                controller: _searchController,
                isCompact: isCompact,
                lowStockOnly: _lowStockOnly,
                onSearchChanged: (value) => setState(() => _searchTerm = value),
                onLowStockChanged: (value) =>
                    setState(() => _lowStockOnly = value),
              ),
              const SizedBox(height: 12),
              if (_visibleItems.isEmpty)
                const _EmptyInventory()
              else if (isDesktop)
                _InventoryTable(
                  items: _visibleItems,
                  onItemTap: _showItemDetails,
                )
              else
                _InventoryList(
                  items: _visibleItems,
                  onItemTap: _showItemDetails,
                ),
              if (!isDesktop) const SizedBox(height: 10),
              if (!isDesktop)
                Text(
                  '${_visibleItems.length} Artikel',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
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
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 18 : 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          if (!isCompact) ...[
            const Text(
              'LAGER /',
              style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Text(
            'Bestand',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Icon(Icons.circle, size: 8, color: Color(0xFF5B9B70)),
          const SizedBox(width: 8),
          Text(
            isCompact ? 'Demo' : 'Lokale Demo-Daten',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 16,
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
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      color: const Color(0xFF1E3028),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 18, 32),
            child: Row(
              children: [
                const Icon(Icons.grid_view_rounded, color: Color(0xFFA8D1B2)),
                const SizedBox(width: 10),
                Text(
                  'WAREHOUSE',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Divider(color: Color(0xFF3C4D43), height: 1),
          const Padding(
            padding: EdgeInsets.all(18),
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

class _InventoryToolbar extends StatelessWidget {
  const _InventoryToolbar({
    required this.controller,
    required this.isCompact,
    required this.lowStockOnly,
    required this.onSearchChanged,
    required this.onLowStockChanged,
  });

  final TextEditingController controller;
  final bool isCompact;
  final bool lowStockOnly;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onLowStockChanged;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: isCompact ? Axis.vertical : Axis.horizontal,
      children: [
        Expanded(
          flex: isCompact ? 0 : 1,
          child: TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Artikel, Nummer oder Standort suchen',
              prefixIcon: Icon(Icons.search, size: 19),
            ),
          ),
        ),
        SizedBox(height: isCompact ? 8 : 0, width: isCompact ? 0 : 12),
        FilterChip(
          avatar: const Icon(Icons.warning_amber_rounded, size: 17),
          label: const Text('Niedriger Bestand'),
          selected: lowStockOnly,
          onSelected: onLowStockChanged,
          showCheckmark: false,
          side: BorderSide(color: lowStockOnly ? _green : _line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ],
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
    );
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
  });

  final String name;
  final String sku;
  final String location;
  final int quantity;
  final int minimum;

  bool get isLowStock => quantity <= minimum;
}

const _demoItems = [
  InventoryItem(
    name: 'USB-C Netzteil 65 W',
    sku: 'PWR-065-USB',
    location: 'A-01-03',
    quantity: 42,
    minimum: 10,
  ),
  InventoryItem(
    name: 'Ethernet-Kabel Cat 6, 2 m',
    sku: 'CBL-C6-002',
    location: 'A-02-01',
    quantity: 8,
    minimum: 12,
  ),
  InventoryItem(
    name: 'M.2 SSD 1 TB',
    sku: 'SSD-M2-1TB',
    location: 'B-04-02',
    quantity: 17,
    minimum: 5,
  ),
  InventoryItem(
    name: 'USB-C Dockingstation',
    sku: 'DOCK-USBC-04',
    location: 'B-01-05',
    quantity: 4,
    minimum: 6,
  ),
  InventoryItem(
    name: 'Wireless Barcode-Scanner',
    sku: 'SCAN-WL-02',
    location: 'C-01-01',
    quantity: 11,
    minimum: 4,
  ),
];