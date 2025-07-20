# App

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Guide de Configuration d'un Nouveau Projet Flutter avec Firebase

Ce guide détaille les étapes pour créer un nouveau projet Flutter et le configurer avec Firebase (y compris l'authentification et Firestore), en se basant sur la configuration de ce projet.

### 1. Créer un Nouveau Projet Flutter

Ouvrez votre terminal et exécutez la commande suivante pour créer un nouveau projet Flutter :
```bash
flutter create nom_de_votre_projet
```
Remplacez `nom_de_votre_projet` par le nom que vous souhaitez donner à votre application.

### 2. Configurer Firebase

#### a. Créer un projet Firebase
1.  Allez sur la [console Firebase](https://console.firebase.google.com/).
2.  Cliquez sur **"Ajouter un projet"** et suivez les instructions pour créer un nouveau projet.

#### b. Enregistrer votre application sur Firebase
1.  Dans le tableau de bord de votre projet Firebase, cliquez sur l'icône Android pour ajouter une nouvelle application Android.
2.  Remplissez le champ **"Nom de package Android"**. Vous pouvez le trouver dans votre projet Flutter dans le fichier `android/app/build.gradle.kts`, à la ligne `applicationId`.
3.  Cliquez sur **"Enregistrer l'application"**.

#### c. Ajouter le fichier de configuration Google Services
1.  Téléchargez le fichier `google-services.json` fourni par Firebase.
2.  Placez ce fichier dans le répertoire `android/app/` de votre projet Flutter.

#### e. Sécuriser les clés d'API

**Important :** Le fichier `google-services.json` contient des informations sensibles. Pour des raisons de sécurité, il ne doit jamais être inclus dans le contrôle de version (Git).

1.  Ouvrez le fichier `.gitignore` à la racine de votre projet.
2.  Ajoutez la ligne suivante à la fin du fichier pour vous assurer que `google-services.json` est bien ignoré :

    ```
    /android/app/google-services.json
    ```

#### d. Ajouter les dépendances Firebase à Flutter
Ouvrez le fichier `pubspec.yaml` et ajoutez les dépendances Firebase nécessaires. Pour ce projet, nous avons utilisé :
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.1.1
  firebase_auth: ^5.1.1
  cloud_firestore: ^5.0.2
```
Après avoir ajouté les dépendances, exécutez `flutter pub get` dans votre terminal.

### 3. Configuration Android

#### a. Modifier le fichier `android/build.gradle.kts`
Ajoutez le plugin Google Services au niveau du projet. Assurez-vous que le bloc `plugins` contient :
```kotlin
plugins {
    // ... autres plugins
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

#### b. Modifier le fichier `android/app/build.gradle.kts`
1.  Appliquez le plugin Google Services au niveau de l'application en ajoutant cette ligne en haut du fichier :
    ```kotlin
    plugins {
        // ... autres plugins
        id("com.google.gms.google-services")
    }
    ```
2.  **Correction du `minSdkVersion`** : Pour assurer la compatibilité avec les bibliothèques Firebase, la version minimale du SDK Android a dû être augmentée. Dans le bloc `defaultConfig`, modifiez la valeur de `minSdk` :
    ```kotlin
    android {
        // ...
        defaultConfig {
            // ...
            minSdk = 23 // La valeur a été changée de flutter.minSdkVersion à 23
            targetSdk = flutter.targetSdkVersion
            // ...
        }
        // ...
    }
    ```
    Cette modification est cruciale pour éviter les erreurs de build liées à des API non disponibles dans les anciennes versions d'Android.

### 4. Initialiser Firebase dans l'application

Dans le fichier `lib/main.dart`, vous devez initialiser Firebase avant de lancer l'application.

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ce fichier est généré automatiquement

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
```
**Note :** Vous devrez peut-être exécuter `flutterfire configure` pour générer le fichier `firebase_options.dart` si ce n'est pas déjà fait.

### 5. Utiliser Firestore

Une fois Firestore ajouté à `pubspec.yaml` et Firebase initialisé, vous pouvez obtenir une instance de Firestore pour interagir avec votre base de données :

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Pour ajouter une donnée
FirebaseFirestore.instance.collection('users').add({'name': 'John Doe'});

// Pour récupérer des données
FirebaseFirestore.instance.collection('users').get().then((querySnapshot) {
  for (var doc in querySnapshot.docs) {
    print(doc.data());
  }
});
```

En suivant ces étapes, vous devriez avoir un projet Flutter fonctionnel et entièrement configuré avec Firebase et Firestore.
