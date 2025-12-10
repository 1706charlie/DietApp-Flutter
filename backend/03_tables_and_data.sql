set search_path to public, auth;
-- on delete cascade : Supprime automatiquement toutes les lignes enfants lorsque la ligne parent est supprimee -- PARENT : tricount (id : cle primaire), ENFANT : participation (tricount_id : cle etrangère)
-- on delete restrict : Interdit la suppression de la ligne parent si des lignes enfants existent

/* ---------------------------------------------------------
   groupes_alimentaires
--------------------------------------------------------- */
drop table if exists groupes_alimentaires cascade;
create table groupes_alimentaires (
                                      id            serial primary key,
                                      libelle       varchar(255) not null unique
);
create unique index uq_groupes_alimentaires_libelle  -- contrainte d'unicite mise en dehors de la table pour pouvoir utiliser les fonctions lower() et trim()
on groupes_alimentaires (lower(trim(libelle)));


insert into groupes_alimentaires (libelle) values
                                               ('Produits de viande et produits de substitution'),
                                               ('Poissons, mollusques et crustacés'),
                                               ('Œufs'),
                                               ('Produits laitiers et produits de soja enrichis en calcium'),
                                               ('Huiles et graisses'),
                                               ('Produits de sucres'),
                                               ('Produits céréaliers'),
                                               ('Légumes et légumineuses'),
                                               ('Fruits, noix et graines'),
                                               ('Produits fermiers'),
                                               ('Denrées alimentaires pour nourrissons, enfants en bas-âge'),
                                               ('Alimentation pour sportifs'),
                                               ('Alimentation végétarienne'),
                                               ('Boissons'),
                                               ('Plats'),
                                               ('Divers');

select setval('groupes_alimentaires_id_seq', (select max(id)
                                              from groupes_alimentaires));

/* ---------------------------------------------------------
   nutriments
--------------------------------------------------------- */
drop table if exists nutriments cascade;
create table nutriments (
                            id            serial primary key,
                            code          varchar(255) not null,
                            libelle       varchar(255) not null,
                            unite         varchar(255) not null,
                            commentaire   text         default null
);

create unique index uq_nutriments_code
on nutriments (lower(trim(code)));


insert into nutriments (code, libelle, unite) values
                                                  ('energie_kcal',            'Énergie',                     'kcal'),
                                                  ('energie_kj',              'Énergie',                     'kJ'),
                                                  ('proteines',               'Protéines',                   'g'),
                                                  ('lipides',                 'Lipides',                     'g'),
                                                  ('acides_gras_satures',     'Acides gras saturés',         'g'),
                                                  ('acides_gras_mono',        'Acides gras mono-insaturés',  'g'),
                                                  ('acides_gras_poly',        'Acides gras poly-insaturés',  'g'),
                                                  ('acides_gras_omega_3',     'Acides gras Omega-3',         'g'),
                                                  ('acides_gras_omega_6',     'Acides gras Omega-6',         'g'),
                                                  ('acides_lino',             'Acides linoléiques',          'g'), -- à vérifier
                                                  ('acides_gras_trans',       'Acides gras trans',           'g'), -- à vérifier
                                                  ('cholesterol',             'Cholestérol',                 'mg'),
                                                  ('glucides_digestibles',    'Glucides digestibles',        'g'),
                                                  ('sucres',                  'Sucres',                      'g'),
                                                  ('amidon',                  'Amidon',                      'g'),
                                                  ('fibres',                  'Fibres',                      'g'),
                                                  ('eau',                     'Eau',                         'g'),
                                                  ('sodium',                  'Sodium',                      'mg'),
                                                  ('potassium',               'Potassium',                   'mg'),
                                                  ('calcium',                 'Calcium',                     'mg'),
                                                  ('phosphore',               'Phosphore',                   'mg'),
                                                  ('magnesium',               'Magnésium',                   'mg'),
                                                  ('fer',                     'Fer',                         'mg'),
                                                  ('cuivre',                  'Cuivre',                      'mg'),
                                                  ('zinc',                    'Zinc',                        'mg'),
                                                  ('selenium',                'Sélénium',                    'µg'),
                                                  ('vit_a_eq',                'Vitamine A (activité)',       'µg'),
                                                  ('vit_b1',                  'Vitamine B1',                 'mg'),
                                                  ('vit_b2',                  'Vitamine B2',                 'mg'),
                                                  ('vit_b12',                 'Vitamine B12',                'µg'),
                                                  ('vit_c',                   'Vitamine C',                  'mg'),
                                                  ('vit_d',                   'Vitamine D',                  'µg');

select setval('nutriments_id_seq', (select max(id)
                                    from nutriments));

/* ---------------------------------------------------------
    aliments
--------------------------------------------------------- */
drop table if exists aliments cascade;
create table aliments (
                          id                 serial primary key,
                          user_id            integer not null references users(id),
                          libelle            varchar(255) not null,
                          groupe_id          integer not null references groupes_alimentaires(id),
    -- Champs nutritionnels (quantité pour 100 g) :
                          energie_kcal        decimal(6,1) null,
                          energie_kj          decimal(6,1) null,
                          proteines           decimal(6,2) null,
                          lipides             decimal(6,2) null,
                          acides_gras_satures decimal(6,2) null,
                          acides_gras_mono    decimal(6,2) null,
                          acides_gras_poly    decimal(6,2) null,
                          acides_gras_omega_3 decimal(6,2) null,
                          acides_gras_omega_6 decimal(6,2) null,
                          acides_lino         decimal(8,2) null,
                          acides_gras_trans   decimal(8,2) null,
                          cholesterol         decimal(6,1) null,
                          glucides_digestibles decimal(6,2) null,
                          sucres             decimal(6,2) null,
                          amidon             decimal(6,2) null,
                          fibres             decimal(6,2) null,
                          eau                decimal(6,1) null,
                          sodium             decimal(8,1) null,
                          potassium          decimal(8,1) null,
                          calcium            decimal(8,1) null,
                          phosphore          decimal(8,1) null,
                          magnesium          decimal(8,1) null,
                          fer                decimal(6,2) null,
                          cuivre             decimal(6,2) null,
                          zinc               decimal(6,2) null,
                          selenium           decimal(8,2) null,
                          vit_a_eq           decimal(8,1) null,
                          vit_b1             decimal(6,2) null,
                          vit_b2             decimal(6,2) null,
                          vit_b12            decimal(6,2) null,
                          vit_c              decimal(8,1) null,
                          vit_d              decimal(6,2) null,
    -- Métadonnées
                          source             varchar(255) null ,
                          updated_at         timestamp not null default current_timestamp
);
comment on table aliments is 'Compo nutritionnelle pour 100 g de produit';

insert into aliments (user_id, libelle, groupe_id, energie_kcal, energie_kj, proteines, lipides, acides_gras_satures, acides_gras_mono, acides_gras_poly, acides_gras_omega_3, acides_gras_omega_6, acides_lino, acides_gras_trans, cholesterol, glucides_digestibles, sucres, amidon, fibres, eau, sodium, potassium, calcium, phosphore, magnesium, fer, cuivre, zinc, selenium, vit_a_eq, vit_b1, vit_b2, vit_b12, vit_c, vit_d, source) VALUES
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Huile d''olive', 5, 900, NULL, NULL, 100.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Beurre non salé', 5, 742, NULL, 0.5, 82.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.5, NULL, NULL, NULL, NULL, 5.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Graines de chia', 9, 366, NULL, 19.0, 30.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'graines de citrouille', 9, 580, NULL, 24.4, 45.6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 15.2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Graines de lin', 9, 497, NULL, 19.5, 36.8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7.5, 2.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Graines de pavot', 9, 507, NULL, 20.0, 41.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4.2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Graines de sésame grillé', 9, 594, NULL, 23.8, 53.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2.9, 0.8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Graines de tournesol', 9, 628, NULL, 20.5, 53.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 12.5, 1.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Son de blé', 9, 262, NULL, 16.4, 4.9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 15.5, 3.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Amandes', 9, 580, NULL, 20.0, 51.3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 9.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Arachide', 9, 593, NULL, 24.0, 49.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Noix - amandes non grillées', 9, 589, NULL, 21.1, 50.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 6.9, NULL, NULL, 12.9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Noisettes', 9, 704, NULL, 14.0, 67.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 6.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Noix', 9, 687, NULL, 15.0, 67.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2.7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Noix du Brésil', 9, 701, NULL, 15.0, 67.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Noix de Cajou', 9, 592, NULL, 18.2, 43.8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 29.8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Noix de Coco', 9, 358, NULL, 3.3, 33.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 6.2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Noix de Pécan', 9, 716, NULL, 9.2, 71.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'pignon de pin', 9, 697, NULL, 13.7, 68.4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pistache', 9, 584, NULL, 20.0, 48.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 18.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Olive', 9, 155, NULL, 1.3, 15.7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Avocats', 9, 205, NULL, 1.5, 20.6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Œuf entier', 3, 154, 644.0, 12.6, 11.2, 3.7, 5.1, 1.8, 0.1, 1.7, 1.5, 0.1, 352.0, 0.8, 0.8, 0.0, 0.0, 74.0, 116.0, 125.0, 91.0, 312.0, 9.0, 2.9, 0.1, 2.3, 11.0, 179.0, 0.08, 0.46, 1.63, 0.0, 14.4, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Jaune œuf', 3, 355, 1484.0, 16.7, 31.9, 9.2, 13.2, 4.4, 0.4, 4.0, 3.8, 0.1, 1226.0, 0.2, 0.2, 0.0, 0.0, 48.0, 64.0, 103.0, 139.0, 584.0, 20.0, 5.5, 0.1, 3.5, 50.0, 540.0, 0.2, 0.5, 3.54, 0.0, 29.5, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'blanc œuf', 3, 44, 182.0, 10.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.0, 0.0, 88.0, 159.0, 142.0, 12.0, 12.0, 10.0, 0.1, 0.0, 0.1, 6.0, 0.0, 0.03, 0.35, 0.65, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pain gris', 7, 250, 1056.0, 9.0, 1.7, 0.4, 0.6, 0.7, 0.1, 0.6, 0.6, 0.0, 30.0, 47.3, 2.0, 45.1, 4.5, 36.0, 480.0, 195.0, 39.0, 152.0, 49.0, 1.7, 0.2, 1.4, 5.0, 0.0, 0.15, 0.02, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pain blanc', 7, 256, 1082.0, 8.4, 1.4, 0.4, 0.4, 0.5, 0.1, 0.5, 0.5, 0.0, 24.0, 51.2, 2.2, 48.3, 2.9, 35.0, 488.0, 139.0, 23.0, 92.0, 24.0, 1.0, 0.1, 0.8, 5.0, 0.0, 0.12, 0.03, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pain multicéréales', 7, 252, 1059.0, 9.9, 3.1, 0.5, 1.0, 1.0, 0.0, 0.8, 0.8, 0.0, 0.0, 44.4, 1.7, 42.0, 4.2, 36.0, 495.0, 226.0, 50.0, 192.0, 69.0, 2.1, 0.2, 1.5, 5.0, 0.0, 0.17, 0.07, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pain complet', 7, 243, 1020.0, 11.4, 1.9, 0.4, 0.4, 1.0, 0.1, 0.8, 0.8, 0.0, 35.0, 41.9, 1.5, 40.4, 6.7, 37.0, 420.0, 285.0, 35.0, 223.0, 73.0, 2.6, 0.3, 1.8, 6.0, 0.0, 0.28, 0.06, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pistolet', 7, 294, 1231.0, 9.5, 3.2, 1.3, 1.0, 0.9, 0.1, 0.8, 0.8, 0.1, 31.0, 55.0, 0.0, 55.0, 3.7, 27.0, 520.0, 149.0, 23.0, 100.0, 27.0, 1.2, 0.1, 0.9, 4.0, 0.0, 0.06, 0.06, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Baguette blanche', 7, 251, 1062.0, 8.5, 1.3, 0.2, 0.5, 0.5, 0.1, 0.4, 0.4, 0.0, 32.0, 50.5, 1.6, 49.0, 2.2, 35.0, 535.0, 145.0, 27.0, 90.0, 93.0, 1.1, 0.1, 0.8, 5.0, 0.0, 0.09, 0.05, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Baguette grise', 7, 271, 1150.0, 11.0, 1.5, 0.6, 0.4, 0.5, 0.0, 0.5, 0.5, 0.0, 30.0, 51.3, 2.1, 49.2, 4.0, 30.0, 488.0, 189.0, 26.0, 144.0, 42.0, 1.6, 0.1, 0.8, 5.0, 30.0, 0.18, 0.1, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Biscotte blanche', 7, 408, 1712.0, 12.3, 6.1, 2.5, 2.3, 1.3, 0.1, 1.2, 1.2, 0.0, 4.0, 73.6, 9.1, 64.5, 4.0, 3.0, 329.0, 215.0, 31.0, 195.0, 30.0, 2.6, 0.1, 1.3, 26.0, 0.0, 0.08, 0.14, 0.0, 0.0, 0.4, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Biscotte complète', 7, 391, 1690.0, 12.9, 7.3, 1.9, 2.3, 2.0, 0.1, 1.9, 1.9, 0.0, 2.0, 69.0, 4.5, 64.0, 5.3, 5.0, 607.0, 165.0, 27.0, 192.0, 38.0, 0.8, 0.0, 1.3, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Krisprolls', 7, 407, 1719.0, 9.5, 7.8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 73.0, 8.6, NULL, NULL, NULL, 0.4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Croissant', 7, 446, 1864.0, 9.0, 22.8, 15.3, 6.7, 1.0, 0.2, 0.7, 0.7, 0.7, 42.0, 47.3, 3.9, 43.0, 1.9, 15.0, 426.0, 111.0, 18.0, 74.0, 17.0, 1.3, 0.1, 0.5, 2.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Galette de riz', 7, 387, 1641.0, 7.8, 3.2, 0.7, 1.2, 1.4, 0.0, 1.3, 1.3, 0.0, 3.0, 80.8, 0.9, 79.7, 3.3, 4.0, 111.0, 333.0, 10.0, 324.0, 129.0, 1.2, 0.3, 1.9, 10.0, 0.0, 0.6, 0.03, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Corn Flakes', 7, 376, 1584.0, 8.0, 1.0, 0.2, 0.3, 0.6, 0.0, 0.6, 0.4, 0.1, 0.0, 82.2, 7.3, 75.0, 3.0, 4.0, 613.0, 96.0, 4.0, 58.0, 10.0, 7.0, 0.1, 0.2, 16.0, 0.0, 1.2, 1.3, 0.83, 0.0, 4.6, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Flocons d‘avoine', 7, 372, 1554.0, 13.5, 7.0, 1.4, 2.6, 3.5, 0.0, 0.0, 0.0, 0.5, 0.0, 58.7, 1.2, 57.5, 10.0, 9.0, 5.0, 388.0, 41.0, 386.0, 125.0, 4.2, 0.5, 2.6, 10.0, 0.0, 0.75, 0.15, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Céréales riches en fibres', 7, 334, 1400.0, 14.0, 3.5, 0.7, 0.5, 2.0, 0.0, 0.0, 1.9, 0.0, 0.0, 48.0, 18.0, 30.0, 27.0, 6.0, 380.0, 820.0, 60.0, 610.0, 274.0, 8.8, 0.0, 4.0, 0.0, 0.0, 0.69, 0.88, 1.6, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Grains de riz soufflés au chocolat', 7, 379, 1610.0, 5.6, 2.4, 1.0, 0.9, 0.3, 0.0, 0.3, 0.3, 0.0, 0.0, 83.1, 33.5, 51.0, 2.8, 4.0, 346.0, 351.0, 237.0, 125.0, 55.0, 8.0, 0.4, 1.2, 52.0, 0.0, 1.06, 1.46, 1.85, 0.0, 4.2, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Viandes maigres', 1, 101, 426.0, 20.8, 2.0, 0.8, 0.7, 0.2, 0.0, 0.2, 0.2, 0.0, 56.0, 0.0, 0.0, 0.0, 0.0, 75.0, 54.0, 339.0, 8.0, 204.0, 24.0, 1.6, 0.1, 3.2, 17.0, 0.0, 0.18, 0.24, 1.5, 0.0, 0.5, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Viandes mi-grasses', 1, 167, 697.0, 20.0, 9.6, 3.8, 4.2, 0.8, 0.1, 0.6, 0.6, 0.1, 63.0, 0.0, 0.0, 0.0, 0.0, 69.0, 66.0, 328.0, 10.0, 198.0, 21.0, 1.2, 0.1, 2.8, 12.0, 0.0, 0.27, 0.19, 1.25, 0.0, 0.3, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Viandes grasses', 1, 264, 1104.0, 18.6, 21.1, 8.2, 8.7, 2.7, 0.4, 1.8, 1.3, 0.1, 71.0, 0.0, NULL, NULL, NULL, 58.0, 69.0, 278.0, 7.0, 150.0, 18.0, 1.1, 0.1, 2.6, 12.0, 3.0, 0.3, 0.2, 1.55, 0.0, 0.6, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Jambon fumé cru', 1, 171, 715.0, 24.4, 7.2, 2.7, 3.4, 1.1, 0.1, 0.9, 0.8, 0.1, 69.0, 0.5, 0.3, 0.0, 0.5, 66.0, 1944.0, 320.0, 6.0, 245.0, 24.0, 0.8, 0.1, 1.9, 32.0, 0.0, 0.7, 0.34, 1.8, 0.0, 0.2, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Jambon Cuit', 1, 112, 467.0, 21.5, 2.6, 1.1, 1.5, 0.4, 0.2, 0.2, 0.2, 0.1, 58.0, 0.7, 0.7, 0.0, 0.1, 74.0, 750.0, 347.0, 5.0, 264.0, 26.0, 0.7, 0.0, 2.3, 24.0, 0.0, 0.44, 0.34, 1.42, 11.0, 0.3, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Salami', 1, 355, 1468.0, 19.8, 29.7, 12.1, 14.0, 4.0, 0.3, 3.8, 3.5, 0.1, 66.0, 0.3, 0.2, 0.1, 0.6, 46.0, 1370.0, 293.0, 15.0, 483.0, 17.0, 1.0, 0.1, 2.9, 14.0, 0.0, 0.6, 0.3, 1.9, 0.0, 0.3, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Hamburger végétariens', 13, 206, 858.0, 18.4, 11.5, 2.8, 2.7, 5.5, 0.5, 4.9, 4.9, 0.1, 26.0, 4.5, 2.0, 2.5, 5.8, 58.0, 653.0, 413.0, 184.0, 155.0, 71.0, 3.5, 0.2, 0.8, 0.0, 0.0, 0.0, 0.0, 0.38, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Burger végétariens sans soja', 13, 296, 1237.0, 10.2, 13.9, 3.8, 3.7, 5.9, 0.0, 0.0, 5.3, 0.0, 4.0, 32.0, 0.5, 31.3, 1.8, 42.0, 432.0, 189.0, 185.0, 219.0, 70.0, 3.4, 0.0, 0.5, 0.0, 70.0, 0.11, 0.11, 0.0, 5.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Tempeh', 13, 195, 817.0, 19.0, 10.0, 1.8, 2.7, 5.6, 0.0, 0.0, 3.9, 0.1, 0.0, 1.3, 0.6, 0.6, 6.6, 65.0, 250.0, 402.0, 101.0, 243.0, 80.0, 2.3, 0.5, 1.2, 0.0, 0.0, 0.05, 0.25, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Tofu', 13, 122, 510.0, 13.5, 7.0, 1.2, 1.5, 4.3, 0.4, 3.7, 3.7, 0.0, 0.0, 2.0, 0.5, 1.0, 1.5, 75.0, 6.0, 67.0, 129.0, 130.0, 79.0, 2.0, 0.2, 1.2, 9.0, 0.0, 0.05, 0.02, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Cabillaud', 2, 71, 297.0, 16.4, 0.6, 0.1, 0.1, 0.3, 0.1, 0.1, 0.0, 0.0, 38.0, 0.0, 0.0, 0.0, 0.0, 81.0, 67.0, 380.0, 16.0, 180.0, 30.0, 0.4, 0.0, 0.4, 28.0, 11.0, 0.12, 0.15, 1.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Maatjes = hareng', 2, 174, 726.0, 18.0, 11.3, 3.4, 5.2, 1.6, 0.7, 0.2, 0.1, 0.1, 53.0, 0.0, 0.0, 0.0, 0.0, 67.0, 1051.0, 284.0, 46.0, 240.0, 29.0, 0.8, 0.1, 0.8, 38.0, 36.0, 0.1, 0.25, 6.68, 0.0, 6.1, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Maquereaux', 2, 182, 761.0, 18.7, 11.9, 3.3, 4.7, 2.7, 2.3, 0.3, 0.2, 0.0, 82.0, 0.0, 0.0, 0.0, 0.0, 68.0, 80.0, 380.0, 12.0, 244.0, 30.0, 1.2, 0.1, 0.5, 39.0, 100.0, 0.13, 0.36, 9.0, 0.0, 4.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Saumon', 2, 222, 928.0, 18.4, 16.5, 7.0, 8.8, 0.5, 0.2, 0.3, 0.2, 0.0, 45.0, 0.0, 0.0, 0.0, 0.0, 63.0, 45.0, 372.0, 5.0, 268.0, 28.0, 0.3, 0.0, 0.4, 23.0, 11.0, 0.16, 0.28, 7.25, 1.0, 17.5, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Thon', 2, 114, 476.0, 27.4, 0.5, 0.1, 0.1, 0.1, 0.1, 0.0, 0.0, 0.0, 44.0, 0.0, 0.0, 0.0, 0.0, 72.0, 46.0, 425.0, 12.0, 200.0, 31.0, 0.8, 0.0, 0.5, 200.0, 372.0, 0.12, 0.02, 4.8, 0.0, 1.6, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'saumon fumé', 2, 180, 737.0, 23.0, 11.0, 2.6, 3.1, 3.6, 2.7, 0.5, 0.3, 0.1, 36.0, 0.0, 0.0, 0.0, 0.0, 65.0, 1200.0, 417.0, 10.0, 254.0, 26.0, 0.3, 0.0, 0.4, 32.0, 54.0, 0.33, 0.18, 5.64, 0.0, 5.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'thon à l’huile', 2, 190, 796.0, 26.0, 11.0, 1.8, 2.2, 5.8, 0.6, 5.1, 0.0, 0.0, 51.0, 0.0, 0.0, 0.0, 0.0, 60.0, 881.0, 386.0, 5.0, 294.0, 34.0, 0.9, 0.0, 0.4, 12.0, 0.0, 0.05, 0.06, 3.7, 0.0, 2.8, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'thon conserve', 2, 106, NULL, 24.6, 0.9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Lait battu', 4, 33, 137.0, 2.8, 0.5, 0.2, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 4.3, 4.3, 0.0, 0.0, 91.0, 41.0, 141.0, 115.0, 84.0, 10.0, 0.0, 0.0, 0.3, 1.0, 14.0, 0.04, 0.28, 0.17, 2.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Lait chocolaté demi=écrémé', 4, 71, 297.0, 3.2, 1.5, 1.1, 0.5, 0.1, 0.0, 0.0, 0.0, 0.0, 14.0, 11.5, 1.3, 0.0, 0.0, 83.0, 50.0, 151.0, 12.0, 90.0, 20.0, 0.4, 0.0, 0.8, 1.0, 15.0, 0.03, 0.18, 0.44, 1.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Lait entier', 4, 65, 271.0, 3.3, 3.6, 2.3, 0.9, 0.1, 0.0, 0.1, 0.1, 0.1, 12.0, 4.8, 4.8, 0.0, 0.0, 87.0, 50.0, 159.0, 120.0, 84.0, 10.0, 0.1, 0.0, 0.4, 2.0, 37.0, 0.04, 0.17, 0.37, 1.0, 0.1, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Lait demi-écrémé', 4, 47, 196.0, 3.3, 1.6, 1.0, 0.3, 0.1, 0.0, 0.0, 0.0, 0.1, 5.0, 4.8, 4.8, 0.0, 0.0, 89.0, 42.0, 165.0, 120.0, 94.0, 10.0, 0.0, 0.0, 0.5, 1.0, 22.0, 0.04, 0.18, 0.2, 2.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Lait écrémé', 4, 34, 142.0, 3.3, 0.1, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 4.9, 4.9, 0.0, 0.0, 91.0, 41.0, 162.0, 120.0, 100.0, 10.0, 0.0, 0.0, 0.4, 1.0, 1.0, 0.04, 0.18, 0.23, 2.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'SKYR', 4, 63, NULL, 11.0, 0.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'yaourt nature entier', 4, 67, NULL, 3.4, 1.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 11.2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Fromage blanc entier', 4, 133, 556.0, 7.9, 9.2, 6.5, 2.0, 0.2, 0.0, 0.2, 0.2, 0.0, 35.0, 3.5, 3.5, 0.0, 0.0, 77.0, 40.0, 145.0, 97.0, 105.0, 10.0, 0.1, 0.0, 0.5, 6.0, 27.0, 0.06, 0.11, 0.46, 0.1, 0.2, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Fromage Emmentham', 4, 368, 1535.0, 28.1, 28.1, 18.1, 7.1, 0.6, 0.2, 0.4, 0.4, 0.8, 68.0, 0.0, 0.0, 0.0, 0.0, 41.0, 300.0, 107.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Légumineuse déshydratées', 8, 338, NULL, 22.0, 1.7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 44.0, NULL, NULL, 21.2, NULL, 1.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Lentilles déshydratées', 8, 334, 1397.0, 24.0, 1.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 48.3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Haricots blancs secs', 8, 324, 1356.0, 20.0, 1.7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 43.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Haricots rouges secs', 8, 310, 1298.0, 27.1, 1.4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 37.3, 3.3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pois chiche secs', 8, 355, 1484.0, 21.1, 5.4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 44.8, 4.8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Haricots blancs sauce tomate en conserve', 8, 90, 377.0, 5.3, 0.6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 13.1, 4.3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Haricots blancs en conserve', 8, 97, 408.0, 6.6, 0.7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 12.3, 0.9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Flageolets en conserve', 8, 90, 375.0, 5.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Légumes moyenne', 8, 21, NULL, 1.3, 0.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2.3, NULL, NULL, 2.2, NULL, 10.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Orange (140)', 9, 41, NULL, 1.1, 0.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 8.5, NULL, NULL, 1.6, NULL, 1.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Myrtilles', 9, 43, NULL, 1.0, 0.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 6.0, NULL, NULL, 7.3, NULL, 1.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Banane (130g)', 9, 86, NULL, 1.1, 0.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 19.5, 16.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'PDT nouvelle chaire ferme crue', 8, 71, 303.0, 2.2, 0.3, 0.1, 0.0, 0.2, 0.1, 0.1, 0.0, 0.0, 0.0, 15.1, 0.7, 14.1, 1.2, 81.0, 1.0, 371.0, 6.0, 47.0, 20.0, 0.4, 0.0, 0.3, 0.0, 0.0, 0.1, 0.1, 0.0, 13.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'PDT à chaire ferme non épluchées', 8, 74, 315.0, 2.1, 0.3, 0.1, 0.0, 0.2, 0.1, 0.2, 0.0, 0.0, 0.0, 15.9, 1.0, 14.9, 2.0, 79.0, 4.0, 420.0, 10.0, 48.0, 16.0, 0.7, 0.0, 0.3, 0.0, 0.0, 0.1, 0.1, 0.0, 3.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'PDT cuite épluchée', 16, 8, 296.0, 2.0, 0.3, 0.1, 0.0, 0.2, 0.1, 0.2, 0.0, 0.0, 0.0, 15.1, 1.0, 14.4, 1.4, 81.0, 6.0, 267.0, 5.0, 38.0, 16.0, 0.5, 0.0, 0.3, 0.0, 0.0, 0.1, 0.1, 0.0, 3.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Purée de pdt', 15, 92, 388.0, 2.7, 3.0, 1.8, 0.7, 0.1, 0.0, 0.0, 0.0, 0.0, 9.0, 12.7, 0.0, 12.7, 1.4, 79.0, 16.0, 336.0, 9.0, 48.0, 17.0, 0.4, 0.1, 0.3, 1.0, 28.0, 1.0, 0.04, 0.05, 6.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Frites précuite / huile végétale / grosses coupe', 15, 232, 969.0, 4.5, 7.1, 4.0, 2.5, 0.6, 0.0, 0.6, 0.6, 0.0, 2.0, 38.3, 0.5, 37.8, 0.0, 0.0, 73.0, 363.0, 18.0, 67.0, 19.0, 0.8, 0.0, 0.3, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pâtes complètes non cuites', 15, 351, 1473.0, 12.9, 2.9, 0.4, 0.3, 1.1, 0.1, 1.0, 1.0, 0.0, 0.0, 63.6, 3.6, 60.0, 9.3, 9.0, 2.0, 426.0, 39.0, 330.0, 104.0, 3.9, 0.5, 2.4, 53.0, 0.0, 0.46, 0.4, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'pâtes complètes cuites', 15, 130, 545.0, 5.4, 0.2, 0.1, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 25.7, 0.5, 25.2, 2.7, 69.0, 17.0, 137.0, 21.0, 119.0, 55.0, 1.1, 0.2, 0.8, 26.0, 0.0, 0.13, 0.02, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pâtes aux œufs crues', 15, 373, 1560.0, 14.0, 4.2, 1.0, 1.2, 1.2, 0.1, 1.1, 1.1, 0.0, 95.0, 68.0, 2.6, 65.8, 3.2, 9.0, 37.0, 97.0, 53.0, 216.0, 31.0, 2.1, 0.2, 1.1, 1.0, 18.0, 0.17, 0.09, 0.4, 0.0, 0.3, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Pâtes aux œufs cuites', 15, 124, 516.0, 4.0, 1.0, 0.4, 0.4, 0.2, 0.0, 0.2, 0.2, 0.0, 22.0, 24.2, 0.0, 24.2, 1.1, 72.0, 15.0, 25.0, 14.0, 55.0, 8.0, 0.5, 0.1, 0.3, 16.0, 4.0, 0.02, 0.02, 0.16, 0.0, 0.2, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Semoule de blé dur cru', 7, 349, 1465.0, 11.7, 1.4, 0.2, 0.3, 0.6, 0.0, 0.6, 0.6, 0.0, 0.0, 71.2, 0.0, 70.0, 3.6, 12.0, 5.0, 110.0, 16.0, 128.0, 44.0, 2.0, 0.3, 0.8, 3.0, 8.0, 0.1, 0.06, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Semoule de riz', 7, 346, 1459.0, 7.2, 0.7, 0.1, 0.1, 0.4, 0.0, 0.4, 0.4, 0.0, 0.0, 77.8, 1.0, 76.8, 0.3, 13.0, 7.0, 120.0, 11.0, 120.0, 13.0, 0.4, 0.2, 0.6, 1.0, 0.0, 0.08, 0.04, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Riz poli non cuit', 7, 347, 1468.0, 7.4, 1.1, 0.2, 0.3, 0.5, 0.0, 0.4, 0.4, 0.0, 0.0, 76.5, 0.5, 76.5, 1.0, 13.0, 5.0, 150.0, 11.0, 145.0, 13.0, 0.6, 0.4, 1.3, 10.0, 0.0, 0.23, 0.03, 0.28, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Riz poli cuit', 7, 131, 549.0, 3.1, 0.4, 0.1, 0.1, 0.1, 0.0, 0.1, 0.1, 0.0, 0.0, 28.5, 0.0, 28.5, 0.5, 68.0, 3.0, 17.0, 14.0, 40.0, 7.0, 0.4, 0.1, 0.5, 1.0, 0.0, 0.02, 0.0, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Riz complet non cuit', 7, 347, 1470.0, 7.7, 2.4, 0.7, 0.7, 1.2, 0.0, 1.0, 1.0, 0.0, 0.0, 72.2, 1.9, 70.5, 3.1, 14.0, 11.0, 238.0, 18.0, 289.0, 110.0, 2.6, 0.2, 1.6, 2.0, 0.0, 0.25, 0.07, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Riz complet cuit', 7, 152, 635.0, 2.6, 1.1, 0.3, 0.3, 0.4, 0.0, 0.4, 0.4, 0.0, 0.0, 29.6, 0.0, 29.6, 1.5, 65.0, 1.0, 99.0, 4.0, 120.0, 43.0, 0.5, 0.3, 0.7, 2.0, 0.0, 0.14, 0.02, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Riz sauvage cru', 7, 354, 1491.0, 10.0, 0.9, 0.2, 0.6, 0.8, 0.3, 0.4, 0.4, 0.0, 0.0, 75.5, 0.2, 75.4, 2.6, 10.0, 10.0, 427.0, 21.0, 433.0, 177.0, 2.0, 0.5, 6.0, 3.0, 2.0, 0.11, 0.26, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Riz sauvage cuit', 7, 97, 411.0, 4.0, 3.0, 0.1, 0.1, 0.2, 0.1, 0.1, 0.1, 0.0, 0.0, 19.5, 0.0, 19.5, 0.5, 74.0, 3.0, 101.0, 3.0, 82.0, 32.0, 0.6, 0.1, 1.3, 1.0, 0.0, 0.05, 0.09, 0.0, 0.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Boulghour cru', 7, 354, 1500.0, 10.9, 1.5, 0.3, 0.3, 0.9, 0.1, 0.8, 0.8, 0.0, 0.0, 72.2, 0.9, 71.3, 4.0, 10.0, 19.0, 325.0, 29.0, 160.0, 47.0, 0.9, 0.0, 0.0, 0.0, 30.0, 0.28, 0.1, 0.0, 4.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Boulghour cuit', 7, 129, 544.0, 3.8, 0.8, 0.3, 0.2, 0.3, 0.0, 0.3, 0.3, 0.0, 0.0, 25.1, 0.3, 24.8, 2.9, 67.0, 8.0, 95.0, 20.0, 61.0, 19.0, 0.3, 0.0, 0.0, 0.0, 30.0, 0.1, 0.1, 0.0, 4.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Quinoa cru', 7, 369, 1553.0, 13.6, 5.9, 0.9, 1.6, 3.3, 0.5, 2.9, 2.8, 0.0, 0.0, 59.8, 6.1, 53.7, 6.6, 11.0, 4.0, 542.0, 34.0, 324.0, 143.0, 3.8, 0.5, 2.8, 9.0, 15.0, 0.47, 0.15, 0.0, 2.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Quinoa cuit', 7, 95, 402.0, 3.5, 1.8, 0.3, 0.6, 1.0, 0.1, 0.9, 0.9, 0.0, 0.0, 15.4, 0.3, 15.1, 1.9, 77.0, 4.0, 95.0, 29.0, 77.0, 39.0, 0.9, 0.0, 0.0, 0.0, 30.0, 0.15, 0.1, 0.0, 4.0, 0.0, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Biscuits «petit déjeuner» au chocolat', 6, 470, 1967.0, 7.3, 18.7, 8.5, 8.3, 3.0, 0.1, NULL, 2.4, 0.1, 1.0, 67.0, 28.0, 39.0, 5.4, 3.0, 252.0, 241.0, 57.0, 256.0, 79.0, 3.9, 0.5, 1.1, 0.0, 29.0, 0.28, 0.1, 0.0, 0.0, 16.5, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'SKYR', 4, 63, NULL, 11.0, 0.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'yaourt nature entier', 4, 67, NULL, 3.4, 1.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 11.2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Confiture', 6, 249, NULL, 0.5, 0.5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 60.0, 58.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel'),
                                                                                                                                                                                                                                                                                                                                                                                                                                       (2,'Betterfood 6+mois (14,6g)', 11, 393, NULL, 6.8, 6.7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 75.0, 23.0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Nubel');

select setval('aliments_id_seq', (select max(id)
                                  from aliments));


/* ---------------------------------------------------------
   régime sur une journée
--------------------------------------------------------- */

drop table if exists diet_line cascade;
create table diet_line (
    id serial primary key,
    user_id integer not null references users(id) on delete cascade,
    aliment_id integer not null references aliments(id) on delete cascade,
    quantity integer not null,
    unity text not null check (unity in ('g', 'ml', 'portion', 'pièce')),
    frequency integer not null check (frequency > 0),
    updated_at timestamp not null default current_timestamp
);
comment on table diet_line is 'Régime alimentaire sur une journée pour un patient';

-- Table diet_line vide après reset (pas de données de test)


-- /* ---------------------------------------------------------
--    données patient
-- --------------------------------------------------------- */
--
-- /******************************************************************************************
--  *  SCHÉMA « patient_follow-up » – dossier complet pour une prise en charge diététique
--  *  ──────────────────────────────────────────────────────────────────────────────────────
--  *  • Compatible PostgreSQL ≥ 14
--  *  • Toutes les rubriques listées dans le Nutrition Care Process (« Assessment »)
--  *  • Découpage en tables logiques : administration, objectifs, anthropométrie,
--  *    clinique & biologie, habitudes alimentaires, mode de vie, psychosocial,
--  *    consentements, séances de suivi.
--  *  • Clés étrangères « ON DELETE CASCADE » pour éliminer les données orphelines.
--  *  • Quelques énumérations, contraintes et index pour les performances & la cohérence.
--  ******************************************************************************************/
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 1. Types énumérés & domaines
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TYPE gender_type          AS ENUM ('male','female','intersex','other','undisclosed');
-- CREATE TYPE physio_state_type    AS ENUM ('none','pregnancy','lactation','menopause','other');
-- CREATE TYPE stage_change_type    AS ENUM ('precontemplation','contemplation','preparation','action',
--     'maintenance','termination');
-- CREATE TYPE sleep_quality_type   AS ENUM ('excellent','good','fair','poor');
-- CREATE TYPE stress_level_type    AS ENUM ('none','low','moderate','high','extreme');
--
-- -- Limite générique « 10 chiffres avant + 10 après la virgule »
-- CREATE DOMAIN num10_10 AS NUMERIC(20,10);
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 2. Table patient (administratif)
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TABLE patient_follow_up.patients (
--                                             id                   SERIAL PRIMARY KEY,
--                                             last_name            TEXT         NOT NULL,
--                                             first_name           TEXT         NOT NULL,
--                                             date_of_birth        DATE         NOT NULL,
--                                             gender               gender_type  NOT NULL,
--                                             address              TEXT,
--                                             phone                TEXT,
--                                             email                TEXT,
--                                             profession           TEXT,
--                                             work_schedule        TEXT,                  -- ex. "6 h-14 h" (quand impacte les repas)
--                                             mutuelle_details     TEXT,
--                                             created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
--                                             updated_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW()
-- );
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 3. Objectifs & motif de consultation
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TABLE patient_follow_up.goals (
--                                          id            SERIAL PRIMARY KEY,
--                                          patient_id    INTEGER       REFERENCES patient_follow_up.patients(id) ON DELETE CASCADE,
--                                          motive        TEXT          NOT NULL,      -- perte de poids, pathologie, sport…
--                                          objective     TEXT,                       -- idéalement formule SMART
--                                          start_date    DATE          DEFAULT CURRENT_DATE,
--                                          notes         TEXT,
--                                          created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW()
-- );
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 4. Anthropométrie (historique)
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TABLE patient_follow_up.anthropometry (
--                                                  id                  SERIAL PRIMARY KEY,
--                                                  patient_id          INTEGER     REFERENCES patient_follow_up.patients(id) ON DELETE CASCADE,
--                                                  record_date         DATE        NOT NULL DEFAULT CURRENT_DATE,
--                                                  weight_kg           num10_10,
--                                                  height_cm           num10_10,
--                                                  target_weight_kg    num10_10,
--                                                  waist_cm            num10_10,
--                                                  hip_cm              num10_10,
--                                                  body_fat_pct        num10_10,
--                                                  lean_mass_pct       num10_10,
--                                                  notes               TEXT
-- );
--
-- -- Index pour la recherche par patient + date
-- CREATE INDEX ON patient_follow_up.anthropometry(patient_id, record_date DESC);
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 5. Données cliniques & biologiques (snapshot daté)
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TABLE patient_follow_up.clinical (
--                                             id                     SERIAL PRIMARY KEY,
--                                             patient_id             INTEGER     REFERENCES patient_follow_up.patients(id) ON DELETE CASCADE,
--                                             record_date            DATE        NOT NULL DEFAULT CURRENT_DATE,
--
--                                             diagnosed_conditions   TEXT,       -- liste séparée par virgules ou JSON
--                                             medications            TEXT,
--                                             surgeries              TEXT,
--                                             allergies              TEXT,
--                                             family_history         TEXT,
--
--                                             physiological_state    physio_state_type DEFAULT 'none',
--
--     -- Paramètres vitaux
--                                             systolic_bp            num10_10,   -- mmHg
--                                             diastolic_bp           num10_10,
--                                             resting_heart_rate     num10_10,
--
--     -- Analyses sanguines courantes
--                                             glycemia_mmol_l        num10_10,
--                                             hba1c_pct              num10_10,
--                                             total_chol_mmol_l      num10_10,
--                                             hdl_mmol_l             num10_10,
--                                             ldl_mmol_l             num10_10,
--                                             triglycerides_mmol_l   num10_10,
--                                             tsh_mu_l               num10_10,
--                                             ferritin_ug_l          num10_10,
--                                             vit_d_nmoll            num10_10,
--
--                                             notes                  TEXT
-- );
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 6. Habitudes alimentaires
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TABLE patient_follow_up.dietary_habits (
--                                                   id                   SERIAL PRIMARY KEY,
--                                                   patient_id           INTEGER   REFERENCES patient_follow_up.patients(id) ON DELETE CASCADE,
--                                                   record_date          DATE      NOT NULL DEFAULT CURRENT_DATE,
--
--                                                   meal_pattern         TEXT,   -- nb repas, horaires
--                                                   recall_24h           TEXT,   -- journal 24 h
--                                                   food_diary_3d        TEXT,   -- journal 3 jours
--                                                   portion_sizes        TEXT,
--                                                   cooking_methods      TEXT,
--                                                   beverages            TEXT,
--                                                   snacks               TEXT,
--                                                   supplements          TEXT,
--                                                   notes                TEXT
-- );
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 7. Mode de vie
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TABLE patient_follow_up.lifestyle (
--                                              id                     SERIAL PRIMARY KEY,
--                                              patient_id             INTEGER REFERENCES patient_follow_up.patients(id) ON DELETE CASCADE,
--                                              record_date            DATE    NOT NULL DEFAULT CURRENT_DATE,
--
--                                              activity_type          TEXT,
--                                              activity_frequency     TEXT,
--                                              activity_duration_min  INTEGER,
--                                              activity_intensity     TEXT,             -- Ex. "modérée"
--                                              sleep_hours            num10_10,
--                                              sleep_quality          sleep_quality_type,
--                                              stress_level           stress_level_type,
--                                              smoking_status         TEXT,
--                                              alcohol_units_week     num10_10,
--                                              other_substances       TEXT,
--                                              family_context         TEXT,
--                                              socioeconomic_status   TEXT,
--                                              notes                  TEXT
-- );
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 8. Psychosocial & motivation
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TABLE patient_follow_up.psychosocial (
--                                                 id                  SERIAL PRIMARY KEY,
--                                                 patient_id          INTEGER REFERENCES patient_follow_up.patients(id) ON DELETE CASCADE,
--                                                 record_date         DATE    NOT NULL DEFAULT CURRENT_DATE,
--
--                                                 stage_of_change     stage_change_type,
--                                                 perceived_barriers  TEXT,
--                                                 social_support      TEXT,
--                                                 motivation_level    TEXT,     -- échelle ou libre
--                                                 notes               TEXT
-- );
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 9. Consentements & documents
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TABLE patient_follow_up.consents (
--                                             patient_id        INTEGER PRIMARY KEY
--                                                 REFERENCES patient_follow_up.patients(id) ON DELETE CASCADE,
--                                             consent_date      DATE      NOT NULL DEFAULT CURRENT_DATE,
--                                             rgpd_signed       BOOLEAN   NOT NULL DEFAULT TRUE,
--                                             signature_path    TEXT,         -- stockage fichier / blob externe
--                                             created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );
--
-- -- ─────────────────────────────────────────────────────────────
-- -- 10. Séances de suivi
-- -- ─────────────────────────────────────────────────────────────
-- CREATE TABLE patient_follow_up.sessions (
--                                             id               SERIAL PRIMARY KEY,
--                                             patient_id       INTEGER     REFERENCES patient_follow_up.patients(id) ON DELETE CASCADE,
--                                             session_date     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--                                             notes            TEXT,
--                                             plan_path        TEXT         -- lien vers PDF, doc, etc.
-- );
--
-- -- Index pour retrouver rapidement le dernier suivi
-- CREATE INDEX ON patient_follow_up.sessions(patient_id, session_date DESC);
--
-- /*══════════════════════════════════════════════════════════════
--    TRIGGERS de mise à jour automatique du champ updated_at
--   ══════════════════════════════════════════════════════════════*/
-- CREATE OR REPLACE FUNCTION patient_follow_up.touch_updated_at()
--     RETURNS TRIGGER LANGUAGE plpgsql AS $$
-- BEGIN
--     NEW.updated_at := NOW();
--     RETURN NEW;
-- END $$;
--
-- CREATE TRIGGER trg_touch_patient
--     BEFORE UPDATE ON patient_follow_up.patients
--     FOR EACH ROW EXECUTE FUNCTION patient_follow_up.touch_updated_at();

