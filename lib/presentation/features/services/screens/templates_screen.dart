import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_router.dart';
import '../../../widgets/header_screen.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => {},
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(12, 70, 12, 24),
                children: const [
                  _TemplateCard(
                    first: true,
                    price: 12000,
                    title: 'Ishdan bo‘shash arizasi',
                    description: "Ishdan bo‘shash uchun tayyor ariza shabloni",
                  ),
                  _TemplateCard(
                    price: 18000,
                    title: 'Ishdan bo‘shash arizasi',
                    description: "Ishdan bo‘shash uchun tayyor ariza shabloni",
                  ),
                  _TemplateCard(
                    price: 24000,
                    title: 'Ishdan bo‘shash arizasi',
                    description: "Ishdan bo‘shash uchun tayyor ariza shabloni",
                  ),
                ],
              ),
              HeaderScreen(
                title: 'Hujjat shablonlari',
                firstActionIconPath: 'assets/icons/search.svg',
                onFirstActionTap: () => Navigator.pushNamed(context, AppRouter.search),
                secondActionIconPath: 'assets/icons/filter.svg',
                onSecondActionTap: () => Navigator.pushNamed(context, AppRouter.filters),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final bool first;
  final int price;
  final String title;
  final String description;

  const _TemplateCard({
    this.first = false,
    required this.price,
    required this.title,
    required this.description,
  });

  String _formatPrice(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );
  }

  void _openPurchase(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => _PurchaseSheet(
        price: price,
        onPayPressed: (paymentType) {
          // Process payment callback logic here
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.tagBackground,
                child: Icon(
                  Icons.description_outlined,
                  size: 17,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'DOCX',
                          style: TextStyle(fontSize: 14, color: AppTheme.textChoco),
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.textChoco.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const Text(
                          'PDF',
                          style: TextStyle(fontSize: 14, color: AppTheme.textChoco),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.pageBackground,
              border: Border.all(color: AppTheme.textChoco.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, color: AppTheme.textChoco),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppTheme.divider),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatPrice(price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          ' so‘m',
                          style: TextStyle(
                            color: AppTheme.textChoco,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Shablon narxi',
                      style: TextStyle(fontSize: 14, color: AppTheme.textChoco),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: FilledButton(
                  onPressed: () => _openPurchase(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.buttonGold,
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    first ? 'Sotib olish' : 'Ko‘rish',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PurchaseSheet extends StatefulWidget {
  final int price;
  final ValueChanged<String> onPayPressed;

  const _PurchaseSheet({
    super.key,
    int? price,
    required this.onPayPressed,
  }) : price = price ?? 0; // Ensures price is never null

  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends State<_PurchaseSheet> {
  String selected = 'Payme';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        decoration: const BoxDecoration(
          color: AppTheme.pageBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Sotib olish',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PriceLine(price: widget.price),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'To‘lov turi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _Payment(
                            title: 'Payme',
                            iconPath: 'assets/images/payme.png',
                            icon: Icons.payment,
                            selected: selected == 'Payme',
                            onTap: () => setState(() => selected = 'Payme'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Payment(
                            title: 'Uzum bank',
                            iconPath: 'assets/images/uzumbank.png',
                            icon: Icons.account_balance,
                            selected: selected == 'Uzum bank',
                            onTap: () => setState(() => selected = 'Uzum bank'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Payment(
                            title: 'Click',
                            iconPath: 'assets/images/click.png',
                            icon: Icons.circle_outlined,
                            selected: selected == 'Click',
                            onTap: () => setState(() => selected = 'Click'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onPayPressed(selected);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.buttonGold,
                    minimumSize: const Size(0, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    'To‘lovni amalga oshirish',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
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

class _PriceLine extends StatelessWidget {
  final int price;

  const _PriceLine({required this.price});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Shablon narxi:',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Text(
            '$formattedPrice',
            style: const TextStyle(
              fontSize: 20,
              color: AppTheme.buttonGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4,),
          Text(
            'so\'m',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Payment extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String iconPath;

  const _Payment({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.iconPath
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F5F4),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 115,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppTheme.buttonGold : AppTheme.textChoco.withValues(alpha: 0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                  child: Image.asset(iconPath, fit: BoxFit.contain,)),
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                color: AppTheme.divider,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
