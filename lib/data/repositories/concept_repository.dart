import 'dart:convert';

import 'package:economia/core/services/preferences.dart';
import 'package:economia/data/models/concept.dart';

class ConceptRepository {
  List<Concept> getConceptsLocal() {
    try {
      String json = Preferences.getString('ND_concepts');
      if (json.isNotEmpty) {
        List<dynamic> jsonList = jsonDecode(json);
        return jsonList.map((e) => Concept.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void saveConceptsLocal(List<Concept> concepts) {
    String json = jsonEncode(concepts);
    Preferences.setString('ND_concepts', json);
  }
  
  void addConceptLocal(Concept concept) {
    List<Concept> concepts = getConceptsLocal();
    concepts.add(concept);
    saveConceptsLocal(concepts);
  }

  void updateConceptLocal(Concept concept) {
    List<Concept> concepts = getConceptsLocal();
    int index = concepts.indexWhere((c) => c.id == concept.id);
    if (index != -1) {
      concepts[index] = concept;
      saveConceptsLocal(concepts);
    }
  }

  void deleteConceptLocal(Concept concept) {
    List<Concept> concepts = getConceptsLocal();
    int index = concepts.indexWhere((c) => c.id == concept.id);
    if (index != -1) {
      concepts.removeAt(index);
      saveConceptsLocal(concepts);
    }
  }

  void deleteAllConceptsLocal() {
    Preferences.setString('ND_concepts', '');
  }
}
