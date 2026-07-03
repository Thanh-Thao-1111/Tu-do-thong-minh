import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/clothing_color.dart';
import '../models/enums.dart';
import '../models/wardrobe_item.dart';
import '../services/attribute_extraction_service.dart';
import '../services/background_removal_service.dart';
import '../services/image_storage_service.dart';
import '../services/image_validation_service.dart';

/// Các bước của luồng thêm trang phục.
enum AddStep {
  pickImage,    // Chọn / chụp ảnh
  validating,   // Đang kiểm tra chất lượng ảnh
  processing,   // Tách nền + nhận diện thuộc tính
  editing,      // Người dùng xác nhận / chỉnh sửa metadata
}

/// Quản lý trạng thái luồng "Thêm đồ": chọn ảnh → kiểm tra chất lượng
/// → tách nền → nhận diện thuộc tính → người dùng chỉnh sửa → tạo WardrobeItem.
/// Đây chính là pipeline lõi (ảnh → validate → xử lý → metadata) ở dạng ViewModel.
class AddItemViewModel extends ChangeNotifier {
  AddItemViewModel(
    this._bgService,
    this._attrService,
    this._imageStorage, {
    ImageValidationService? validationService,
  }) : _validationService =
            validationService ?? const ImageValidationService();

  final BackgroundRemovalService _bgService;
  final AttributeExtractionService _attrService;
  final ImageStorageService _imageStorage;
  final ImageValidationService _validationService;
  final _uuid = const Uuid();

  AddStep _step = AddStep.pickImage;
  AddStep get step => _step;

  Uint8List? _processedBytes; // ảnh đã tách nền
  Uint8List? get processedBytes => _processedBytes;

  /// Thông báo lỗi validation (null = không có lỗi).
  String? _validationErrorTitle;
  String? _validationErrorMessage;
  String? _validationErrorHint;

  String? get validationErrorTitle => _validationErrorTitle;
  String? get validationErrorMessage => _validationErrorMessage;
  String? get validationErrorHint => _validationErrorHint;

  // ----- Các trường metadata có thể chỉnh sửa -----
  String name = '';
  ClothingCategory category = ClothingCategory.top;
  String? subtype;
  final List<ClothingColor> colors = [];
  final List<StyleTag> styles = [];
  final List<Season> seasons = [];
  final List<Occasion> occasions = [];
  String? pattern;
  String? material;

  // ---------------------------------------------------------------------------
  // Pipeline chính
  // ---------------------------------------------------------------------------

  /// Xử lý sau khi người dùng chọn/chụp ảnh.
  /// Thứ tự: kiểm tra chất lượng → tách nền → nhận diện thuộc tính.
  Future<void> onImagePicked(Uint8List originalBytes) async {
    _clearValidationError();

    // --- Bước 1: Kiểm tra chất lượng ảnh ---
    _step = AddStep.validating;
    notifyListeners();

    final result = await _validationService.validate(originalBytes);
    if (!result.isValid) {
      _validationErrorTitle = result.errorTitle;
      _validationErrorMessage = result.errorMessage;
      _validationErrorHint = result.errorHint;
      _step = AddStep.pickImage;
      notifyListeners();
      return;
    }

    // --- Bước 2: Tách nền + nhận diện thuộc tính ---
    _step = AddStep.processing;
    notifyListeners();

    try {
      _processedBytes = await _bgService.removeBackground(originalBytes);
      final attrs = await _attrService.extract(_processedBytes!);

      // Đổ kết quả nhận diện vào form để người dùng xác nhận/sửa.
      name = attrs.suggestedName ?? '';
      category = attrs.category;
      colors
        ..clear()
        ..addAll(attrs.colors);
      styles
        ..clear()
        ..addAll(attrs.styles);
      seasons
        ..clear()
        ..addAll(attrs.seasons);
      occasions
        ..clear()
        ..addAll(attrs.occasions);
      pattern = attrs.pattern;
      material = attrs.material;

      _step = AddStep.editing;
    } catch (e) {
      // Lỗi không mong đợi trong quá trình xử lý → quay về màn chọn ảnh.
      _validationErrorTitle = 'Xử lý ảnh thất bại';
      _validationErrorMessage =
          'Đã xảy ra lỗi khi xử lý ảnh. Vui lòng thử lại.';
      _validationErrorHint = 'Nếu lỗi tiếp tục, hãy thử chọn ảnh khác.';
      _step = AddStep.pickImage;
    }

    notifyListeners();
  }

  /// Xóa thông báo lỗi validation (gọi khi người dùng đóng dialog lỗi).
  void clearValidationError() {
    _clearValidationError();
    notifyListeners();
  }

  void _clearValidationError() {
    _validationErrorTitle = null;
    _validationErrorMessage = null;
    _validationErrorHint = null;
  }

  // ---------------------------------------------------------------------------
  // Setters metadata
  // ---------------------------------------------------------------------------

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setPattern(String value) {
    pattern = value.trim().isEmpty ? null : value.trim();
    notifyListeners();
  }

  void setMaterial(String value) {
    material = value.trim().isEmpty ? null : value.trim();
    notifyListeners();
  }

  void setCategory(ClothingCategory c) {
    category = c;
    // Loại cụ thể cũ không còn hợp với danh mục mới -> bỏ chọn.
    if (subtype != null && !c.subtypes.contains(subtype)) subtype = null;
    notifyListeners();
  }

  void setSubtype(String? v) {
    subtype = v;
    notifyListeners();
  }

  void setColors(List<ClothingColor> v) {
    colors
      ..clear()
      ..addAll(v);
    notifyListeners();
  }

  void setStyles(List<StyleTag> v) {
    styles
      ..clear()
      ..addAll(v);
    notifyListeners();
  }

  void setSeasons(List<Season> v) {
    seasons
      ..clear()
      ..addAll(v);
    notifyListeners();
  }

  void setOccasions(List<Occasion> v) {
    occasions
      ..clear()
      ..addAll(v);
    notifyListeners();
  }

  bool get canSave => name.trim().isNotEmpty;

  // ---------------------------------------------------------------------------
  // Lưu
  // ---------------------------------------------------------------------------

  /// Tạo WardrobeItem từ dữ liệu form; upload ảnh (Storage hoặc cục bộ).
  Future<WardrobeItem> buildItem() async {
    final id = _uuid.v4();
    String? imageUrl;
    if (_processedBytes != null) {
      imageUrl = await _imageStorage.uploadItemImage(id, _processedBytes!);
    }
    return WardrobeItem(
      id: id,
      name: name.trim(),
      imageUrl: imageUrl,
      category: category,
      subtype: subtype,
      colors: List.of(colors),
      styles: List.of(styles),
      seasons: List.of(seasons),
      occasions: List.of(occasions),
      pattern: pattern,
      material: material,
      createdAt: DateTime.now(),
    );
  }
}
