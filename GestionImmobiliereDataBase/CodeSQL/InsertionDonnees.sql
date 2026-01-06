
-- ============================================================
-- Auteur: Olivier Dunn, Maxime Malette, Thomas Paré, Ahmed Hamissi
-- Date de création: 2025-11-24
-- Description:
-- Script postgreSQL d'insertions de données GestionImmobilière 
-- ============================================================
INSERT INTO Gestion.Adresses (idAdresse, noCivique, rue, ville, codePostal) VALUES
	(1, 101, 'boulevard de Portland', 'Sherbrooke', 'J1H 2K7'),
	(2, 2500, 'boulevard de l''université', 'Sherbrooke', 'J1K 2R1'),
	(3, 201, 'rue King O.', 'Sherbrooke', 'J1H 1P7'),
	(4, 301, 'rue du Plaisir', 'Québec', 'G1R 2B5'),
	(5, 401, 'rue du Soleil', 'Montréal', 'H2X 1Y7'),
	(6, 1550, 'rue Wellington Sud', 'Sherbrooke', 'J1H 5C5'),
	(7, 875, 'rue Galt Ouest', 'Sherbrooke', 'J1H 1Z8'),
	(8, 3450, 'boulevard Saint-François', 'Sherbrooke', 'J1E 2B9'),
	(9, 125, 'rue Alexandre', 'Sherbrooke', 'J1H 2N4'),
	(10, 680, 'avenue du Parc', 'Montréal', 'H2V 4E8');

INSERT INTO Gestion.Proprietaires (idProprietaire, idAdresse, nbPortesPro, nbImmeublesPro) VALUES
	(1, 1, 2, 1),
	(2, 2, 3, 1),
	(3, 3, 4, 1),
	(4, 4, 5, 1),
	(6, 5, 5, 1);

INSERT INTO Gestion.Compagnies (idProprietaire, noTelephone, courriel, nom) VALUES
	(1, '4501234567', 'SGBDdeGestion@usherbrooke.com', 'GestionSGBD'),
	(2, '1112223456', 'gestionImmobliereVailla@gestionVailla.com', 'GestionVailla'),
	(6, '6745616291', 'Compagnie@gestion.com','compagnie');

INSERT INTO Gestion.Particuliers (idProprietaire, noTelephone, courriel, nom, prenom) VALUES
	(3, '9876543210', 'théoJobert@gestionPro.com', 'Jobert', 'Théo'),
	(4, '1234567890', 'CélineDion@chanson.com', 'Dion', 'Céline');

INSERT INTO Gestion.Regles (idRegle, fumeur, chat, chien, bbq) VALUES
	(1, true, true, true, true),
	(2, true, true, false, true),
	(3, true, true, true, false),
	(4,False, true, true, true),
	(6, false, false, true, true);

INSERT INTO Gestion.Inclusions (idInclusion, meuble, chauffage, electricite, internet, eauChaude) VALUES
	(1, true, true, true, true, true),
	(2, true, true, false, true, true),
	(3, true, true, true, false, true),
	(4, False, true, true, true, true),
	(6, false, false, true, true, true);
	
INSERT INTO Gestion.Travaux (idTravail, dateDebut, dateFin, coutEstime, coutFinal, statut, description) VALUES
	(1, '2025-10-24', '2025-10-25', 1000.00, 2500.00,'Termine','Installer des sonnettes'),
	(2, '2026-09-24',NULL, 35.00,NULL,'Prévu', 'Installer extincteur'),
	(3, '2002-12-25', '2003-01-05', 1000.00, 1500.00,'Termine', 'Réno plancher'),
	(4, '2002-12-25', '2003-01-05', 1000.00, 1500.00,'Termine', 'Réno plancher'),
	(5, '2002-12-25', '2003-01-05', 1000.00, 1500.00,'Termine', 'Réno plancher'),
	(6, '2002-12-25', '2003-01-05', 1000.00, 1500.00,'Termine', 'Réno plancher');

INSERT INTO  Gestion.PaiementsTravaux (idPaiementTravail, idTravail, datePaiement, montant, modePaiement, commentaire) VALUES
	(1,1,'2025-11-01',2500.00,'Crédit',NULL),
	(2,3,'2003-01-10', 1500.00,'Comptant',NULL),
	(3,4,'2003-01-10', 1500.00,'Comptant',NULL),
	(4,5,'2003-01-10', 1500.00,'Comptant',NULL),
	(5,6,'2003-01-10', 1500.00,'Comptant',NULL);

INSERT INTO Gestion.ContratsGestion (idContrat, dateDebut, dateFin, montantMensuel, pourcentageGestion, prixRelocation, clauses) VALUES
	(1,'2022-03-06','2026-03-05',250.00,0.02,500.00,NULL),
	(2,'2025-10-12','2026-10-11',250.00,0.02,500.00,NULL),
	(3,'2010-01-01',NULL,500.00,0.03,500.00,NULL),
	(4,'2022-03-15',NULL,100.00,0.03,525.00,NULL),
	(6,'2025-09-27',NULL,100.00,0.03,400.00,NULL);
	
INSERT INTO Gestion.PaimentsGestion (idPaiementGestion, idContrat, datePaiement, montant, modePaiement, commentaire) VALUES
	(1, 1, '2025-04-06',1000.00,'Chèque','Paiement a jour'),
	(2, 2, '2025-11-12',3270.00,'Interac','Paiement a jour'),
	(3, 3, '2025-10-01',5000.00,'Interac','Paiement a jour'),
	(4, 4, '2025-03-15',1200.00,'Interac','Paiement a jour'),
	(5, 4, '2025-04-15',1100.00,'Interac','Paiement a jour');

INSERT INTO Gestion.Immeubles (idImmeuble, idAdresse, idProprietaire, idRegle, nbPortes, nbStationnement, description) VALUES
	(1, 6, 1, 1, 2, 2, 'Duplex 2 stationnement'),
	(2, 7, 2, 2, 3, 3, 'Triplex 3 stationnement'),
	(3, 8, 3, 3, 4, 4, 'Quadruplex 4 stationnement'),
	(4, 9, 4, 4, 5, 5, 'Quintuplex 5 stationnement'),
	(6, 10,6, 6, 5, 5, 'Quintuplex 5 stationnement');

INSERT INTO Gestion.TravauxImmeuble (idImmeuble, idTravail) VALUES
	(1,1),
	(2,2);

INSERT INTO Gestion.Logements (idLogement, idImmeuble, idInclusion, nbPieces, balcon, statut, noPorte, description) VALUES
	(1,1,1,4,False,'Vacant',1,'Plancher rénover'),
	(2,1,1,4,False,'Loué',2,NULL),
	
	(3,2,2,3,False,'Vacant',1,'Plancher rénover'),
	(4,2,2,3,true,'Loué',2,NULL),
	(5,2,2,3,true,'Loué',3, NULL),
	
	(6,3,3,5,False,'Loué',1,NULL),
	(7,3,3,5,False,'Loué',2,NULL),
	(8,3,3,5,False,'Loué',3,NULL),
	(9,3,3,5,False,'Vacant',4,'Plancher rénover'),
	
	(10,4,4,2,False,'Loué',1,NULL),
	(11,4,4,2,False,'Loué',2,NULL),
	(12,4,4,2,False,'Loué',3, NULL),
	(13,4,4,2,False,'Vacant',4,'Plancher rénover'),
	(14,4,4,2,False,'Vacant',5,NULL),
	
	(15,6,6,4,False,'Vacant',1,NULL),
	(16,6,6,4,False,'Vacant',2,NULL),
	(17,6,6,4,False,'Vacant',3, NULL),
	(21,6,6,4,False,'Vacant',4, NULL),
	(22,6,6,4,False,'Vacant',5, NULL);
	
INSERT INTO Gestion.TravauxLogement (idLogement, idTravail) VALUES
	(1,3),
	(3,4),
	(9,5),
	(13,6);

INSERT INTO Gestion.Locataires (idLocataire, idLogement, langue, noTelephone, prenom, nom, courriel, modePaiement, solde) VALUES 
	(1,12,'Français', '4371152227','Locataire9','Locataire9','Locataire9@Test9.com','Comptant',NULL),
	(2,11,'Français', '4373352227','Locataire1','Locataire1','Locataire@Test1.com','Interac',NULL),
	(3,10,'Français', '4375752227','Locataire2','Locataire2','Locataire@Test2.com','Comptant',NULL),
	(4,8,'Français', '4374352227','Locataire3','Locataire3','Locataire@Test3.com','Comptant',-1250.00),
	(5,7,'Français', '4371052227','Locataire4','Locataire4','Locataire@Test4.com','Comptant',NULL),
	(6,6,'Français', '4370952227','Locataire5','Locataire5','Locataire@Test5.com','Comptant',NULL),
	(7,4,'Français', '4376652227','Locataire6','Locataire6','Locataire@Test6.com','Comptant',2000.00),
	(8,2,'Français', '4373452227','Locataire8','Locataire8','Locataire8@Test8.com','Interac',NULL),
	(9,5,'Français', '4376752227','Locataire7','Locataire7','Locataire@Test7.com','Comptant',NULL);
	
INSERT INTO Gestion.Baux (idBail, idLocataire, dateDebut, dateFin, loyer) VALUES
	(1,1,'2025-07-01','2026-06-30',1000.00),
	(2,2,'2025-07-01','2026-06-30',1100.00),
	(3,3,'2025-07-01','2026-06-30',1100.00),
	(4,4,'2025-07-01','2026-06-30',1250.00),
	(5,5,'2025-07-01','2026-06-30',1250.00),
	(6,6,'2025-07-01','2026-06-30',1250.00),
	(7,7,'2025-07-01','2026-06-30',800.00),
	(8,8,'2025-07-01','2026-06-30',800.00),
	(9,9,'2025-07-01','2026-06-30',800.00);
	
INSERT INTO Gestion.PaiementsLocataire (idPaiementsLocataire, idLocataire, datePaiement, montant, periode, commentaire) VALUES
	(1,1,'2025-12-01',1000.00,'Novembre','Aucun retard'),
	(3,3,'2025-12-01',1100.00,'Novembre','Aucun retard'),
	(4,4,'2025-12-01',1250.00,'Novembre','Aucun retard'),
	(5,6,'2025-12-01',1250.00,'Novembre','Aucun retard'),
	(6,7,'2025-12-01',100.00,'Novembre','Premier retard'),
	(7,8,'2025-12-01',800.00,'Novembre','Aucun retard'),
	(8,9,'2025-12-02',200.00,'Novembre','Premier retard');
	
	
