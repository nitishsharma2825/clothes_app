import 'package:clothshopapp/providers/product.dart';
import 'package:clothshopapp/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var editedProduct = Product(
      id: null,
      title: '',
      price: 0,
      imageUrl: '',
      description: '');
  var initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageFocusNode.addListener(imageListener);
    super.initState();
  }

  var _inState = true;
  var isLoading=false;

  @override
  void didChangeDependencies() {
    if (_inState) {
      final productId = ModalRoute
          .of(context)
          .settings
          .arguments as String;
      if (productId != null) {
        editedProduct = Provider.of<Products>(context).findById(productId);
        print(editedProduct.id);
        initValues = {
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price.toString(),
          //'imageUrl': editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = editedProduct.imageUrl;
      }
    }
    _inState = false;
    super.didChangeDependencies();
  }

  void imageListener() {
    if (!_imageFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https') &&
          !_imageUrlController.text.endsWith('.jpeg') &&
          !_imageUrlController.text.endsWith('png')) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> submitForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      isLoading=true;
    });
    if (editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false).updateProduct(editedProduct.id, editedProduct);
      setState(() {
        isLoading=false;
      });
      Navigator.of(context).pop();
    } else {
    try {
      await Provider.of<Products>(context, listen: false)
          .addItem(editedProduct);
    }
    catch(error) {
      await showDialog(context: context, builder: (ctx) =>
          AlertDialog(
            title: Text('Some error occurred'),
            content: Text(error.toString()),
            actions: <Widget>[
              FlatButton(child: Text('Close'), onPressed: () {
                Navigator.of(ctx).pop();
              },)
            ],
          ));
    }
    finally{
      setState(() {
        isLoading = false;
      });
          Navigator.of(context).pop();
    }

    }
    //Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: submitForm)
        ],
      ),
      body: isLoading?Center(child: CircularProgressIndicator(),):Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
            key: _form,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  initialValue: initValues['title'],
                  decoration: InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    editedProduct = Product(
                      id: editedProduct.id,
                      isFavourite: editedProduct.isFavourite,
                      title: value,
                      price: editedProduct.price,
                      imageUrl: editedProduct.imageUrl,
                      description: editedProduct.description,
                    );
                  },
                ),
                TextFormField(
                  initialValue: initValues['price'],
                  decoration: InputDecoration(labelText: 'Price'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  validator: (value) {
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid no.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    editedProduct = Product(
                      id: editedProduct.id,
                      isFavourite: editedProduct.isFavourite,
                      title: editedProduct.title,
                      price: double.parse(value),
                      imageUrl: editedProduct.imageUrl,
                      description: editedProduct.description,
                    );
                  },
                ),
                TextFormField(
                  initialValue: initValues['description'],
                  decoration: InputDecoration(labelText: 'Description'),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  focusNode: _descriptionFocusNode,
                  validator: (value) {
                    if (value.length < 10) {
                      return 'The length should be greater than 10 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    editedProduct = Product(
                      id: editedProduct.id,
                      isFavourite: editedProduct.isFavourite,
                      title: editedProduct.title,
                      price: editedProduct.price,
                      imageUrl: editedProduct.imageUrl,
                      description: value,
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(top: 8, right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? Text('Enter image url')
                          : FittedBox(
                        child: Image.network(
                          _imageUrlController.text,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'ImageUrl'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageFocusNode,
                        onFieldSubmitted: (_) {
                          submitForm();
                        },
                        validator: (value) {
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'Please enter a valid URL';
                          }
                          if (!value.endsWith('.jpg') &&
                              !value.endsWith('png')) {
                            return 'Please enter a valid URL.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          editedProduct = Product(
                            id: editedProduct.id,
                            isFavourite: editedProduct.isFavourite,
                            title: editedProduct.title,
                            price: editedProduct.price,
                            imageUrl: value,
                            description: editedProduct.description,
                          );
                        },
                      ),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
