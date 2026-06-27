import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/categories.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/penny_app_bar.dart';
import '../../../../core/widgets/penny_date_picker.dart';
import '../../domain/entities/expense.dart';
import '../../../scanner/data/datasources/anthropic_datasource.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key, this.prefill, this.scannedItems});

  final Expense? prefill;
  final List<ReceiptItem>? scannedItems;

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merchantCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _date;
  late ExpenseCategory _category;
  late final List<TextEditingController> _itemNameCtrls;
  late final List<TextEditingController> _itemPriceCtrls;

  @override
  void initState() {
    super.initState();
    final p = widget.prefill;
    _merchantCtrl = TextEditingController(text: p?.merchantName ?? '');
    _amountCtrl = TextEditingController(
      text: p != null ? _formatRupiahInput(p.amount) : '',
    );
    _notesCtrl = TextEditingController(text: p?.notes ?? '');
    _date = p?.date ?? DateTime.now();
    _category = p?.category ?? ExpenseCategory.makanan;
    final items = widget.scannedItems ?? [];
    _itemNameCtrls =
        items.map((i) => TextEditingController(text: i.name)).toList();
    _itemPriceCtrls = items
        .map((i) => TextEditingController(text: _formatRupiahInput(i.price)))
        .toList();
  }

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    for (final c in _itemNameCtrls) {
      c.dispose();
    }
    for (final c in _itemPriceCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatRupiahInput(int amount) {
    final f = NumberFormat('#,###', 'id_ID');
    return f.format(amount);
  }

  Future<void> _pickDate() async {
    final picked = await PennyDatePicker.show(
      context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _date = DateTime(
            picked.year,
            picked.month,
            picked.day,
            DateTime.now().hour,
            DateTime.now().minute,
          ));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = CurrencyFormatter.parse(_amountCtrl.text);
    final expense = Expense(
      id: widget.prefill?.id,
      merchantName: _merchantCtrl.text.trim(),
      amount: amount,
      date: _date,
      category: _category,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (widget.prefill?.id != null) {
      context.read<ExpenseBloc>().add(UpdateExpense(expense));
    } else {
      context.read<ExpenseBloc>().add(AddExpense(expense));
    }
    Navigator.of(context).pop(expense);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.prefill?.id != null;
    return Scaffold(
      appBar: PennyAppBar(
        eyebrow: isEdit ? 'EDIT ENTRI' : 'CATATAN BARU',
        title: isEdit ? 'Edit pengeluaran' : 'Pengeluaran baru',
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                const _SectionLabel('JUMLAH'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Rp',
                        style: GoogleFonts.fraunces(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          autofocus: !isEdit,
                          inputFormatters: [_RupiahInputFormatter()],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            hintText: '0',
                            contentPadding: EdgeInsets.zero,
                            hintStyle: GoogleFonts.fraunces(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                          style: GoogleFonts.fraunces(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.6,
                            color: AppColors.textPrimary,
                          ),
                          validator: (v) {
                            final n = CurrencyFormatter.parse(v ?? '');
                            if (n <= 0) return 'Masukkan jumlah yang valid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('DETAIL'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _merchantCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama tempat',
                    hintText: 'Mis. Indomaret, GoFood',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                    ),
                    child: Text(DateUtilsX.formatFull(_date)),
                  ),
                ),
                if (_itemNameCtrls.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const _SectionLabel('ITEM TERDETEKSI'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: List.generate(_itemNameCtrls.length, (i) {
                        final isLast = i == _itemNameCtrls.length - 1;
                        return Container(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                      color: AppColors.divider,
                                      width: 0.8,
                                    ),
                                  ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _itemNameCtrls[i],
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 90,
                                child: TextFormField(
                                  controller: _itemPriceCtrls[i],
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [_RupiahInputFormatter()],
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                const _SectionLabel('KATEGORI'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExpenseCategory.values.map((c) {
                    final selected = c == _category;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _category = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.charcoal : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.charcoal
                                : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: c.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              c.label,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('CATATAN (opsional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Tambahkan catatan...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child:
                      Text(isEdit ? 'Simpan perubahan' : 'Simpan pengeluaran'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _RupiahInputFormatter extends TextInputFormatter {
  final NumberFormat _f = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }
    final number = int.parse(digits);
    final formatted = _f.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
