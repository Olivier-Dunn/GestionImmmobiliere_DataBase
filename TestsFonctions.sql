--============================================
--Auteur : Olivier Dunn
--Date de dernière modification : 2025-12-05
--Description:
-- Contient l'ensemble des tests utiles pour chacune
-- des fonctions et procédure de la base de données
--=============================================


--Script de base pour tous les test de fonctions

--Données de base pour les test.
--Adresse de test
INSERT INTO Gestion.Adresses (idAdresse, noCivique, rue, ville, codePostal) VALUES
	(11, 680, 'Adresse test', 'TEST', 'TEST');
--Proprietaire de test
INSERT INTO Gestion.Proprietaires (idProprietaire, idAdresse, nbPortesPro, nbImmeublesPro) VALUES
	(5, 11, 1, 1);
--Règles de tests
INSERT INTO Gestion.Regles (idRegle, fumeur, chat, chien, bbq) VALUES
	(5, true, true, true, true);
--Inclusion de tests
INSERT INTO Gestion.Inclusions (idInclusion, meuble, chauffage, electricite, internet, eauChaude) VALUES
	(5, true, true, true, true, true);
--Immeuble de test
INSERT INTO Gestion.Immeubles (idImmeuble, idAdresse, idProprietaire, idRegle, nbPortes, nbStationnement, description) VALUES	
	(5, 11,5, 5, 5, 5, 'Immeuble TEST');






--=============================================================
--Test Fonction 1 : Gestion.f_getLoyer(unLocataire)

--Test 1 le locataire n'existe pas (Retourne NULL)
SELECT * FROM Gestion.f_getLoyer(97);

--Insertion de logement
INSERT INTO Gestion.Logements (idLogement, idImmeuble, idInclusion, nbPieces, balcon, statut, noPorte, description)
VALUES (19,5,5,4,False,'Loué',5, NULL);
--Insertion Locataire test
INSERT INTO Gestion.Locataires(idLocataire, idLogement, langue, noTelephone, prenom, nom, courriel, modePaiement)
VALUES 	(97,19,'Français', '4371152227','Test','Normal','CourrielNormal','Comptant');

SELECT * FROM Gestion.f_getLoyer(97);
--Test 2 Le locataire n'a pas de bail (Retourne NULL)

-- Test 3 Retourne 1000.00
INSERT INTO Gestion.Baux(idBail,idLocataire, dateDebut, dateFin, loyer)
VALUES (97,97,'2025-12-04', '2026-12-03', 1000.00);

SELECT * FROM Gestion.f_getLoyer(97);

--===========================================================================
--Test Fonction 2 : Gestion.f_getStatutLogement(unLogement)
INSERT INTO Gestion.Logements (idLogement, idImmeuble, idInclusion, nbPieces, balcon, statut, noPorte, description)
VALUES	--Test 1 Loué
		(100,5,5,4,False,'Loué',5, NULL),

		--Test 2 Vacant
		(101,5,5,4,False,'Vacant',5, NULL),

		--Test 3 En réno
		(102,5,5,4,False,'En réno',5, NULL);
		-- Test 4 N'existe pas
		SELECT * FROM Gestion.f_getStatutLogement(100);
		SELECT * FROM Gestion.f_getStatutLogement(101);
		SELECT * FROM Gestion.f_getStatutLogement(102);
		SELECT * FROM Gestion.f_getStatutLogement(103);
--==========================================================================
--Test Fonction 3 : Gestion.f_getSolde(unLocataire)
--test 1
INSERT INTO Gestion.Locataires(idLocataire, idLogement, langue, noTelephone, prenom, nom, courriel, modePaiement, solde)
VALUES --Test 1 pas de solde dans le insert
		(100,18,'Français', '4371152227','Test','Normal','CourrielNormal','Comptant', NULL),
	
		
		--Test 2 avec un solde en entré.
	(101,19,'Français', '4371152227','Test','Normal','CourrielNormal','Comptant', 100.00);

		SELECT * FROM Gestion.f_getSolde(100);
		SELECT * FROM Gestion.f_getSolde(101);

INSERT INTO Gestion.Baux(idBail,idLocataire, dateDebut, dateFin, loyer)
VALUES	-- Test 3 le locataire à un loyer
		(106,100,'2025-12-04', '2026-12-03', 1000.00);
		SELECT * FROM Gestion.f_getSolde(100);
--============================================================================
--Fonction 4 : Gestion.f_initialiserLoyerAuSolde(NEW) à partir d’un trigger.
								-- Test 1 : locataire sans solde
--Création du  logement de test:
INSERT INTO Gestion.Logements(idLogement, idImmeuble, idInclusion, nbPieces, balcon, statut, noPorte, description)
VALUES (21, 5, 5, 4, FALSE, 'Vacant', 20, 'Logement de test');
-- Création du locataire avec solde NULL
INSERT INTO Gestion.Locataires(idLocataire, idLogement, langue, noTelephone, prenom, nom, courriel, modePaiement, solde)
VALUES (201, 20, 'Français', '4371152227', 'Test', 'SansSolde', 'courriel@test', 'Comptant', NULL);

-- Vérification avant bail : doit retourner NULL
SELECT * FROM Gestion.f_getSolde(201);

-- Insertion d’un bail avec loyer 
INSERT INTO Gestion.Baux(idBail, idLocataire, dateDebut, dateFin, loyer)
VALUES (201, 201, '2025-12-04', '2026-12-03', 1200.00);

-- Vérification après bail : doit retourner 1200.00
SELECT * FROM Gestion.f_getSolde(201);

									-- Test 2 : locataire avec solde négatif (2 mois gratuits)
--Création du  logement de test:
INSERT INTO Gestion.Logements(idLogement, idImmeuble, idInclusion, nbPieces, balcon, statut, noPorte, description)
VALUES (22, 5, 5, 4, FALSE, 'Vacant', 20, 'Logement de test');

-- Création du locataire avec solde = -2000.00 (si loyer = 1000.00)
INSERT INTO Gestion.Locataires(idLocataire, idLogement, langue, noTelephone, prenom, nom, courriel, modePaiement, solde)
VALUES (301, 22, 'Français', '4371152227', 'Test', 'Gratuit', 'courriel@test', 'Comptant', -2000.00);

-- Vérification avant bail : doit retourner -2000.00
SELECT * FROM Gestion.f_getSolde(301);

-- Insertion d’un bail avec loyer 1000.00
INSERT INTO Gestion.Baux(idBail, idLocataire, dateDebut, dateFin, loyer)
VALUES (301, 301, '2025-12-04', '2026-12-03', 1000.00);

-- Vérification après bail : doit retourner -1000.00 (le trigger ajoute le loyer au solde négatif)
SELECT * FROM Gestion.f_getSolde(301);
									-- TEST 3 solde déjà initialiser > 0

--Création du  logement de test:
INSERT INTO Gestion.Logements(idLogement, idImmeuble, idInclusion, nbPieces, balcon, statut, noPorte, description)
VALUES (25, 5, 5, 4, FALSE, 'Vacant', 20, 'Logement de test');

-- Création du locataire avec solde = 500.00
INSERT INTO Gestion.Locataires(idLocataire, idLogement, langue, noTelephone, prenom, nom, courriel, modePaiement, solde)
VALUES (304, 25, 'Français', '4371152227', 'Test', 'Positif', 'courriel@test', 'Comptant', 500.00);

-- Vérification avant bail : doit retourner 500.00
SELECT * FROM Gestion.f_getSolde(304);

-- Insertion d’un bail avec loyer 1000.00
INSERT INTO Gestion.Baux(idBail, idLocataire, dateDebut, dateFin, loyer)
VALUES (304, 304, '2025-12-04', '2026-12-03', 1000.00);

-- Vérification après bail : doit toujours retourner 500.00
SELECT * FROM Gestion.f_getSolde(304);

--==============================================================================================
--Fonction 5 : Gestion.f_bailActif(unBail)										
										-- Test 1 : bail expiré
-- Insertion d’un logement test
INSERT INTO Gestion.Logements(idLogement, idImmeuble, idInclusion, nbPieces, balcon, statut, noPorte, description)
VALUES (40,5,5,4,FALSE,'Vacant',30,NULL);
-- Insertion d'un locataire
INSERT INTO Gestion.Locataires(idLocataire, idLogement, langue, noTelephone, prenom, nom, courriel, modePaiement, solde)
VALUES (80,40,'Français','4371152227','Test','Locataire','locataire100@test.com','Comptant',NULL);
-- Insertion d’un bail avec date de fin passée
INSERT INTO Gestion.Baux(idBail,idLocataire,dateDebut,dateFin,loyer)
VALUES (400,80,'2024-01-01','2024-12-31',1000.00);

-- TEST doit retourner FALSE
SELECT Gestion.f_bailActif(400);

										--Test 2  Bail actif (retourne TRUE)
-- Insertion d’un logement test
INSERT INTO Gestion.Logements(idLogement,idImmeuble,idInclusion,nbPieces,balcon,statut,noPorte,description)
VALUES (41,5,5,4,FALSE,'Vacant',31,NULL);
-- Insertion d'un locataire
INSERT INTO Gestion.Locataires(idLocataire,idLogement,langue,noTelephone,prenom,nom,courriel,modePaiement,solde)
VALUES (81,41,'Français','4371152227','Test','Actif','locataire101@test.com','Comptant',NULL);
-- Insertion d’un bail avec date de fin passée
INSERT INTO Gestion.Baux(idBail,idLocataire,dateDebut,dateFin,loyer)
VALUES (401,81,'2025-12-01','2026-12-01',1200.00);
-- TEST doit retourner TRUE
SELECT Gestion.f_bailActif(401);
--======================================================================================
--FONCTION 6 : Gestion.f_getBail(unLocataire)
										--Test 1 : locataire avec bail existant
--Insertion d'un logement de test
INSERT INTO Gestion.Logements(idLogement,idImmeuble,idInclusion,nbPieces,balcon,statut,noPorte,description)
VALUES (83,5,5,4,FALSE,'Vacant',40,NULL);
--Insertion d'un locataire de test
INSERT INTO Gestion.Locataires(idLocataire,idLogement,langue,noTelephone,prenom,nom,courriel,modePaiement,solde)
VALUES (83,83,'Français','4371152227','Test','AvecBail','locataire200@test.com','Comptant',NULL);
--Insertion d'un bail de test
INSERT INTO Gestion.Baux(idBail,idLocataire,dateDebut,dateFin,loyer)
VALUES (500,83,'2025-12-01','2026-12-01',1000.00);
--Test doit retourner 500
SELECT Gestion.f_getBail(83);


										--Test 2 : locataire sans bail
--Insertion d'un logement de test
INSERT INTO Gestion.Logements(idLogement,idImmeuble,idInclusion,nbPieces,balcon,statut,noPorte,description)
VALUES (84,5,5,4,FALSE,'Vacant',41,NULL);
--Insertion d'un locataire de test
INSERT INTO Gestion.Locataires(idLocataire,idLogement,langue,noTelephone,prenom,nom,courriel,modePaiement,solde)
VALUES (501,84,'Français','4371152227','Test','SansBail','locataire201@test.com','Comptant',NULL);
--Test doit retourner NULL
SELECT Gestion.f_getBail(84);
--==============================================================================================
--FONCTION 7 : Gestion.f_locataireBailActif(NEW)
										--Test 1 : locataire avec bail actif (le trigger ne bloque rien)
--Insertion d'un logement test
INSERT INTO Gestion.Logements(idLogement,idImmeuble,idInclusion,nbPieces,balcon,statut,noPorte,description)
VALUES (87,5,5,4,FALSE,'Vacant',50,NULL);
--Insertion d'un locataire test
INSERT INTO Gestion.Locataires(idLocataire,idLogement,langue,noTelephone,prenom,nom,courriel,modePaiement,solde)
VALUES (87,87,'Français','4371152227','Test','Actif','locataire300@test.com','Comptant',NULL);
--Insertion d'un bail test
INSERT INTO Gestion.Baux(idBail,idLocataire,dateDebut,dateFin,loyer)
VALUES (87,87,'2025-12-01','2026-12-01',1000.00);
--Insertion d'un paiement test
INSERT INTO Gestion.PaiementsLocataire(idPaiementsLocataire,idLocataire,datePaiement,montant,periode)
VALUES (87,87,'2025-12-05',500.00,'Décembre');

										--Test 2 : locataire sans bail (le trigger bloque avec exception)
INSERT INTO Gestion.Logements(idLogement,idImmeuble,idInclusion,nbPieces,balcon,statut,noPorte,description)
VALUES (88,5,5,4,FALSE,'Vacant',51,NULL);

INSERT INTO Gestion.Locataires(idLocataire,idLogement,langue,noTelephone,prenom,nom,courriel,modePaiement,solde)
VALUES (88,88,'Français','4371152227','Test','SansBail','locataire301@test.com','Comptant',NULL);

-- Tentative de paiement sans bail actif doit bloquer
INSERT INTO Gestion.PaiementsLocataire(idPaiementsLocataire,idLocataire,datePaiement,montant,periode)
VALUES (78,88,'2025-12-05',500.00,'Décembre');
--======================================================================================================
--Fonction 8 : Gestion.f_updateSoldePaiement(NEW)
										--Test update solde après paiement
--Insertion de logement test
INSERT INTO Gestion.Logements(idLogement,idImmeuble,idInclusion,nbPieces,balcon,statut,noPorte,description)
VALUES (90,5,5,4,FALSE,'Vacant',60,NULL);
--Insertion de locataire test
INSERT INTO Gestion.Locataires(idLocataire,idLogement,langue,noTelephone,prenom,nom,courriel,modePaiement,solde)
VALUES (90,90,'Français','4371152227','Test','Paiement','locataire400@test.com','Comptant',NULL);
--Insertion d'un bail test
INSERT INTO Gestion.Baux(idBail,idLocataire,dateDebut,dateFin,loyer)
VALUES (90,90,'2025-12-01','2026-12-01',1000.00);
--vérification du solde qui doit retourner 1000.00
SELECT Gestion.f_getSolde(90);

--Insertion d'un paiement
INSERT INTO Gestion.PaiementsLocataire(idPaiementsLocataire,idLocataire,datePaiement,montant,periode)
VALUES (90,90,'2025-12-05',500.00,'Novembre');
--Test doit retourner 500.00
SELECT Gestion.f_getSolde(90);
--===========================================================================================================
--FONCTION 9 : Gestion.f_genererProfitProprietaire(unePeriode)
--Test fonction generer profit
							--Test mois de janvier retourne 0.00 pour chaque propriétaire
SELECT idProprietaire, CashFlow
FROM Gestion.f_genererProfitProprietaire('Janvier');
--Insertion du logement
INSERT INTO Gestion.Logements(idLogement,idImmeuble,idInclusion, nbPieces,balcon,statut,noPorte,description)
VALUES (200,5,3,4,FALSE,'Vacant',200,NULL);
--Insertion d'un locataire qui fera 4 paiement
INSERT INTO Gestion.Locataires(idLocataire,idLogement,langue,noTelephone,prenom,nom,courriel,modePaiement,solde)
VALUES (300,200,'Français','4371152227','Test','Janvier','locataire300@test.com','Comptant',4000.00);
-- Insertion de son bail test
INSERT INTO Gestion.Baux(idBail,idLocataire,dateDebut,dateFin,loyer)
VALUES (1000,300,'2025-01-01','2025-12-31',1000.00);
--Insertion de ces 4 paiements
INSERT INTO Gestion.PaiementsLocataire(idPaiementsLocataire,idLocataire,datePaiement,montant,periode)
VALUES (500,300,'2025-01-05',500.00,'Janvier'),
       (501,300,'2025-01-10',600.00,'Janvier'),
       (502,300,'2025-01-15',700.00,'Janvier'),
       (503,300,'2025-01-20',800.00,'Janvier');
									--Test le propriétaire 5 devrait avoir 2600.00$ de revenu.
SELECT idProprietaire, CashFlow
FROM Gestion.f_genererProfitProprietaire('Janvier');
--=============================================================================================================
--FONCTION 10 : Gestion.f_afficherDureeBail(unBail)
									--Test bail inexistant
--Le bail n'existe pas 
SELECT* FROM Gestion.f_afficherDureeBail(905);
--Test afficher durée bail
INSERT INTO Gestion.Logements(idLogement,idImmeuble,idInclusion,nbPieces,balcon,statut,noPorte,description)
VALUES (70,5,5,4,FALSE,'Vacant',70,NULL);
--Insertion locataire de test
INSERT INTO Gestion.Locataires(idLocataire,idLogement,langue,noTelephone,prenom,nom,courriel,modePaiement,solde)
VALUES (500,70,'Français','4371152227','Test','Durée','locataire500@test.com','Comptant',NULL);
--Insertion bail de test
INSERT INTO Gestion.Baux(idBail,idLocataire,dateDebut,dateFin,loyer)
VALUES (905,500,'1999-01-01','2042-12-31',1000.00);
									--Test doit retourner 1999-01-01 au 2042-12-31
SELECT Gestion.f_afficherDureeBail(905);
--==============================================================================================================
--FONCTION 11: Gestion.afficherPrenomLocataire(unLocataire)
--Test sur un locataire qui n'existe pas
SELECT Gestion.afficherPrenomLocataire(502);
--Insertion du logement pour le test
INSERT INTO Gestion.Logements(idLogement,idImmeuble,idInclusion,nbPieces,balcon,statut,noPorte,description)
VALUES (72,5,5,4,FALSE,'Vacant',70,NULL);
--Insertion locataire de test
INSERT INTO Gestion.Locataires(idLocataire,idLogement,langue,noTelephone,prenom,nom,courriel,modePaiement,solde)
VALUES (502,72,'Français','4371152227','JeSuisUnPrénom','EtMoiJeSuisUnNom','PrénomNom@test.com','Comptant',NULL);
--Doit retourner "JeSuisUnPrénom EtMoiJeSuisUnNom"
SELECT Gestion.afficherPrenomLocataire(502);
--==============================================================================================================
--FONCTION 12 : Gestion.afficherAdresse(unAdresse)
										--Test sur une adresse qui n'existe pas
SELECT * FROM Gestion.afficherAdresse(999);

--Insertion d'une adresse pour le test
INSERT INTO Gestion.Adresses (idAdresse, noCivique, rue, ville, codePostal) VALUES
	(999, 1234,'Rue du test', 'La ville des tests','A1A1A1');
										--Test sur l'adresse
SELECT * FROM Gestion.afficherAdresse(999);
--==============================================================================================================
-- FONCTION 13 : Gestion.f_liste_des_baux_solde()


INSERT INTO Gestion.Adresses (idAdresse, noCivique, rue, ville, codePostal) VALUES
	(100, 101, 'boulevard de Portland', 'Sherbrooke', 'J1H 2K7'),
	(200, 2500, 'boulevard de l''université', 'Sherbrooke', 'J1K 2R1'),
	(300, 201, 'rue King O.', 'Sherbrooke', 'J1H 1P7'),
	(400, 301, 'rue du Plaisir', 'Québec', 'G1R 2B5'),
	(500, 401, 'rue du Soleil', 'Montréal', 'H2X 1Y7'),
	(600, 1550, 'rue Wellington Sud', 'Sherbrooke', 'J1H 5C5'),
	(700, 875, 'rue Galt Ouest', 'Sherbrooke', 'J1H 1Z8'),
	(800, 3450, 'boulevard Saint-François', 'Sherbrooke', 'J1E 2B9'),
	(900, 125, 'rue Alexandre', 'Sherbrooke', 'J1H 2N4'),
	(1000, 680, 'avenue du Parc', 'Montréal', 'H2V 4E8');
--Insertion des propriétaire
INSERT INTO Gestion.Proprietaires (idProprietaire, idAdresse, nbPortesPro, nbImmeublesPro) VALUES
	(500, 100, 2, 1),
	(501, 200, 3, 1);
--Insertion du type de proprio
INSERT INTO Gestion.Compagnies (idProprietaire, noTelephone, courriel, nom) VALUES
	(500, '4501234567', 'AdresseCompagnie@usherbrooke.com', 'TestCompagnie');
--Insertion de l'autre type de proprio
INSERT INTO Gestion.Particuliers (idProprietaire, noTelephone, courriel, nom, prenom) VALUES
	(501, '9876543210', 'Particulier@gestionPro.com', 'JesuisUn', 'Particulier');
--Insertion des regles et inclusion
INSERT INTO Gestion.Regles VALUES
	(600, true, true, true, true);
INSERT INTO Gestion.Inclusions VALUES
	(700, true, true, true, true, true);
--Insertion des Immeubles
INSERT INTO Gestion.Immeubles VALUES
	(100, 600, 500, 600, 2, 2, 'TEST'),
	(200, 700, 500, 600, 2, 2, 'TEST'),
	(300, 800, 501, 600, 2, 2, 'TEST'),
	(400, 900, 501, 600, 2, 2, 'TEST'),
	(500, 100, 501, 600, 2, 2, 'TEST');
--Insertion des logements
INSERT INTO Gestion.Logements VALUES
	(1000,100,700,4,False,'Loué',1,NULL),
	(2000,100,700,4,False,'Loué',2,NULL),
	(3000,200,700,4,False,'Loué',1,NULL),
	(4000,200,700,4,False,'Loué',2,NULL),
	(5000,300,700,4,False,'Loué',1,NULL),
	(6000,300,700,4,False,'Loué',2,NULL),
	(7000,400,700,4,False,'Loué',1,NULL),
	(8000,400,700,4,False,'Vacant',2,NULL),
	(9000,500,700,4,False,'Loué',1,NULL),
	(10000,500,700,4,False,'Vacant',2,NULL);

--Insertion des Locataires
INSERT INTO Gestion.Locataires VALUES 
	(1000,1000,'Français', '1111111111','Locataire1','Test','Locataire1@Test.com','Interac',NULL),
	(2000,2000,'Français', '2222222222','Locataire2','Test','Locataire2@Test.com','Interac',NULL),
	(3000,3000,'Français', '3333333333','Locataire3','Test','Locataire3@Test.com','Interac',NULL),
	(4000,4000,'Français', '4444444444','Locataire4','Test','Locataire4@Test.com','Interac',NULL),
	(5000,5000,'Français', '5555555555','Locataire5','Test','Locataire5@Test.com','Interac',NULL),
	(6000,6000,'Français', '6666666666','Locataire6','Test','Locataire6@Test.com','Interac',NULL),
	(7000,7000,'Français', '7777777777','Locataire7','Test','Locataire7@Test.com','Interac',NULL),
	(8000,9000,'Français', '8888888888','Locataire8','Test','Locataire8@Test.com','Interac',NULL);
--Insertion des baux
INSERT INTO Gestion.Baux VALUES
	(10000,1000,'2024-07-01','2025-06-30',100.00),
	(20000,2000,'2025-07-01','2026-06-30',200.00),
	(30000,3000,'2025-07-01','2026-06-30',300.00),
	(40000,4000,'2025-07-01','2026-06-30',400.00),
	(50000,5000,'2025-07-01','2026-06-30',500.00),
	(60000,6000,'2025-07-01','2026-06-30',600.00),
	(70000,7000,'2025-07-01','2026-06-30',700.00),
	(80000,8000,'2025-07-01','2026-06-30',800.00);
--Insertion des paiements de locataires
INSERT INTO Gestion.PaiementsLocataire VALUES
	(100,4000,'2025-12-01',400.00,'Novembre','Aucun retard'),
	(200,2000,'2025-12-01',200.00,'Novembre','Aucun retard'),
	(300,3000,'2025-12-01',300.00,'Novembre','Aucun retard');

SELECT * FROM Gestion.f_liste_des_baux_solde();
--========================================================================================
--Procédure 1: Gestion.p_soldeNouveauMois()
					--TEST
--Avant
SELECT * FROM Gestion.f_liste_des_baux_solde();
--Appel de la procédure
CALl Gestion.p_soldeNouveauMois();
--Après
SELECT * FROM Gestion.f_liste_des_baux_solde();
--=========================================================================================
--CONTRAINTE verif_date_[table]

--TEST 1 insertion valide
INSERT INTO Gestion.Travaux (idTravail, dateDebut, dateFin, coutEstime, coutFinal, statut, description) 
	VALUES (200, '1900-01-01', '2000-01-01','10.00', '10.00', 'Prévu', NULL);
--AUCUN BLOCAGE ATTENDU

--TEST 2 dateFin null INSERTION VALIDE
INSERT INTO Gestion.Travaux (idTravail, dateDebut, dateFin, coutEstime, coutFinal, statut, description) 
	VALUES (201, '1900-01-01', NULL,'10.00', '10.00', 'Prévu', NULL);
--AUCUN BLOCAGE ATTENDU

--TEST 3 INSERTION INVALIDE
INSERT INTO Gestion.Travaux (idTravail, dateDebut, dateFin, coutEstime, coutFinal, statut, description) 
	VALUES (202, '2000-01-01', '1900-01-01','10.00', '10.00', 'Prévu', NULL);
--BLOCAGE ATTENDU