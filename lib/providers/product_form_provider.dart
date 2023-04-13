import 'package:products_app/models/product.dart';
import 'package:products_app/screens/screens.dart';

class ProductFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Product product;

  ProductFormProvider(this.product);
  updateAvaliability(bool value) {
    print(value);
    product.available = value;
    notifyListeners();
  }

  bool isValidForm() {
    print(product.name);
    print(product.available);
    print(product.price);

    final validForm = formKey.currentState?.validate();

    return validForm ?? false;
  }
}
