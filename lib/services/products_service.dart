import 'dart:convert';
import 'dart:io';
import 'package:products_app/models/models.dart';
import 'package:products_app/screens/screens.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      'https://flutter-varios-9ea3d-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  Product? selectedProduct;

  File? newPictureFile;

  bool isLoading = true;
  bool isSaving = false;
  ProductsService() {
    loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();
    final url = '$_baseUrl/products.json';
    final resp = await http.get(Uri.parse(url));
    final Map<String, dynamic> productsMap = json.decode(resp.body);

    productsMap.forEach(
      (key, value) {
        final tempProduct = Product.fromMap(value);
        tempProduct.id = key;
        products.add(tempProduct);
      },
    );

    isLoading = false;
    notifyListeners();
    return products;
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.id == null) {
      await createProduct(product);
    } else {
      updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.parse('$_baseUrl/products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    final decodedData = resp.body;

    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.parse('$_baseUrl/products.json');
    final resp = await http.post(url, body: product.toJson());
    final decodedData = jsonDecode(resp.body);
    product.id = decodedData['name'];
    products.add(product);
    return product.id!;
  }

  void updateSelectedProductImage(String path) {
    selectedProduct?.picture = path;
    newPictureFile = File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (newPictureFile == null) return null;

    isSaving = true;
    notifyListeners();
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dx0pryfzn/image/upload?upload_preset=autwc6pa');

    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);
    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      return null;
    }
    newPictureFile = null;
    final decodeData = json.decode(resp.body);
    return decodeData['secure_url'];
  }
}
