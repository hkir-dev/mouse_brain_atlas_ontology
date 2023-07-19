---
layout: ontology_detail
id: mbao
title: Mouse Brain Atlas Ontology
jobs:
  - id: https://travis-ci.org/hkir-dev/mouse_brain_atlas_ontology
    type: travis-ci
build:
  checkout: git clone https://github.com/hkir-dev/mouse_brain_atlas_ontology.git
  system: git
  path: "."
contact:
  email: 
  label: 
  github: 
description: Mouse Brain Atlas Ontology is an ontology...
domain: stuff
homepage: https://github.com/hkir-dev/mouse_brain_atlas_ontology
products:
  - id: mbao.owl
    name: "Mouse Brain Atlas Ontology main release in OWL format"
  - id: mbao.obo
    name: "Mouse Brain Atlas Ontology additional release in OBO format"
  - id: mbao.json
    name: "Mouse Brain Atlas Ontology additional release in OBOJSon format"
  - id: mbao/mbao-base.owl
    name: "Mouse Brain Atlas Ontology main release in OWL format"
  - id: mbao/mbao-base.obo
    name: "Mouse Brain Atlas Ontology additional release in OBO format"
  - id: mbao/mbao-base.json
    name: "Mouse Brain Atlas Ontology additional release in OBOJSon format"
dependencies:
- id: uberon
- id: mba_uberon_bridge

tracker: https://github.com/hkir-dev/mouse_brain_atlas_ontology/issues
license:
  url: http://creativecommons.org/licenses/by/3.0/
  label: CC-BY
activity_status: active
---

Enter a detailed description of your ontology here. You can use arbitrary markdown and HTML.
You can also embed images too.

