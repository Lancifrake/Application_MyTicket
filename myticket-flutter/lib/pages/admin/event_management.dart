import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EventManagementPage extends StatefulWidget {
  @override
  _EventManagementPageState createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final _formKey = GlobalKey<FormState>();
  String eventName = '';
  String eventDate = '';
  String eventLocation = '';
  String eventPrice = '';
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des Événements"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Nom de l'événement"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un nom";
                  }
                  return null;
                },
                onSaved: (value) => eventName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Date de l'événement"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer une date";
                  }
                  return null;
                },
                onSaved: (value) => eventDate = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Lieu de l'événement"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un lieu";
                  }
                  return null;
                },
                onSaved: (value) => eventLocation = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Prix du ticket"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un prix";
                  }
                  return null;
                },
                onSaved: (value) => eventPrice = value!,
              ),
              SizedBox(height: 20),
              _image == null
                  ? Text("Aucune image sélectionnée.")
                  : Image.file(_image!, height: 150),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Sélectionner une image"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Sauvegarde de l'événement avec les données
                    print("Événement enregistré: $eventName, $eventDate, $eventLocation, $eventPrice");
                  }
                },
                child: Text("Créer l'événement"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
