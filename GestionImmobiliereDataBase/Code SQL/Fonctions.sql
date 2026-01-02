--============================================
--Auteur : Olivier Dunn, Thomas Paré
--Date de dernière modification : 2025-12-05
--Description:
--Ensemble de TRIGGER, FONCTION et PROCÉDURE contenu dans le SGBD
-- de la compagnie de gestion
--=============================================

-- ============================================
-- Fonction: f_getLoyer()
-- Description:
-- Fonction qui retourne le loyer d'un locataire
-- IN (ENTIER): L'identifiant d'un locataire
-- RETOUR (NUMERIC): Le loyer du locataire est retourné
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.f_getLoyer
(
	unLocataire Gestion.Locataires.idLocataire%TYPE
)
RETURNS Gestion.Baux.loyer%TYPE
LANGUAGE PLPGSQL
AS $$
DECLARE
	v_leLoyer Gestion.Baux.loyer%TYPE;
BEGIN
	--Récupération du loyer
	SELECT loyer
	INTO v_leLoyer
	FROM Gestion.Baux
	WHERE idLocataire = unLocataire;

	--Retour du loyer
	RETURN v_leLoyer;
END;
$$;
	
-- ============================================
-- Fonction: f_getStatutLogement()
-- Description:
-- Fonction qui retourne le statut d'un logement
-- IN (ENTIER): Un identifiant de logement
-- RETOUR (STRING): Le statut du logement
-- ============================================

CREATE OR REPLACE FUNCTION Gestion.f_getStatutLogement
(
	g_unLogement  Gestion.Logements.idLogement%TYPE
)
RETURNS Gestion.Logements.statut%TYPE
LANGUAGE PLPGSQL
AS $$
DECLARE	--Déclaration du statut qui sera retourné
	v_le_statut Gestion.Logements.statut%TYPE;
BEGIN
	--Vérifie si le logement existe sinon raise Exception
	IF NOT EXISTS (
		SELECT 1
		FROM Gestion.Logements
		WHERE idLogement = g_unLogement)
	THEN
		RAISE EXCEPTION 'Le logement % n''existe pas',g_unLogement;
	END IF;

	--Affecte la le statut associé a l'identifiant passé en paramètre a la variable déclaré
	SELECT statut
	INTO v_le_statut
	FROM Gestion.Logements
	WHERE idLogement = g_unLogement;
	--Retourne le statut
	RETURN v_le_statut;
END;
$$;

-- ============================================
-- Fonction: f_getSolde()
-- Description:
-- Fonction qui retourne le solde d'un locataire
-- IN (ENTIER): Un identifiant de locataire
-- RETOUR (NUMERIC): Retourne Le solde du locataire
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.f_getSolde
(
	unLocataire Gestion.Locataires.idLocataire%TYPE
)
RETURNS Gestion.Locataires.solde%TYPE
LANGUAGE PLPGSQL
AS $$
DECLARE
	v_leSolde Gestion.Locataires.solde%TYPE;
BEGIN
	--Select le solde du locataire entré en parametre
	SELECT solde
	INTO v_leSolde
	FROM Gestion.Locataires
	WHERE idLocataire = unLocataire;
	
	RETURN v_leSolde;
END;
$$;

-- ============================================
-- Fonction: f_InitialiserLoyerAuSolde
-- Description:
-- Fonction qui initialise le montant du loyer au solde du locataire lors de la création du bail
-- RETOUR TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.f_initialiserLoyerAuSolde()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_solde NUMERIC(10,2);
BEGIN
    -- CRécupérer le solde actuel
    SELECT solde
    INTO v_solde
    FROM Gestion.Locataires
    WHERE idLocataire = NEW.idLocataire;

    -- Si le solde est NULL ou <= 0  ajouter le loyer
    IF v_solde IS NULL OR v_solde <= 0.00 THEN
        UPDATE Gestion.Locataires
        SET solde = COALESCE(solde, 0.00) + NEW.loyer
        WHERE idLocataire = NEW.idLocataire;
    END IF;

    --Si le solde est >0 on laisse le solde comme ca.

    RETURN NEW;
END;
$$;

--=============================================
-- TRIGGER t_ajouterLoyerAuSolde
-- Description:
-- Fonction qui ajoute le montant du loyer au solde du locataire lors de la création d'un bail
-- ============================================
CREATE OR REPLACE TRIGGER t_ajouterLoyerAuSolde
AFTER INSERT OR UPDATE 
ON Gestion.Baux
FOR EACH ROW
EXECUTE FUNCTION Gestion.f_initialiserLoyerAuSolde();

-- ============================================
-- Fonction: f_bailActif()
-- Description:
-- Fonction qui retourne vrai si le bail est actif
-- IN (ENTIER): Un identifiant de bail
-- RETOUR (BOOLEAN): True si le bail est actif
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.f_bailActif
(
	unBail Gestion.Baux.idBail%TYPE
)
RETURNS BOOLEAN
LANGUAGE PLPGSQL
AS $$
DECLARE
	v_dateFin DATE;
	v_estActif BOOLEAN;
BEGIN
	--Récupère la date de fin du bail en paramètre
	SELECT dateFin
	INTO  v_dateFin
	FROM Gestion.Baux
	WHERE idBail = unBail;
	--Si la date de fin est dans le futur
	v_estActif := v_dateFin >= CURRENT_DATE;
	RETURN v_estActif;
	-- Si le bail en paramètre n'existe pas (ne devrait pas arriver)
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- Le bail n'existe pas (considéré comme inactif)
			RETURN FALSE;
END;
$$;
-- ============================================
-- Fonction: f_getBail()
-- Description:
-- Récupere l'identifiant d'un bail de locataire
-- IN (ENTIER): Un identifiant de locataire
-- RETOUR (ENTIER): L'identifiant du bail
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.f_getBail
(
	unLocataire Gestion.Locataires.idLocataire%TYPE
)
RETURNS INTEGER
LANGUAGE PLPGSQL
AS $$
DECLARE
	v_leBail INTEGER;
BEGIN
	--Select le bail du locataire entré en parametre
	SELECT idBail
	INTO v_leBail
	FROM Gestion.Baux
	WHERE idLocataire = unLocataire;

	RETURN v_leBail;
END;
$$;

-- ============================================
-- Procédure: p_soldeNouveauMois()
-- Description:
-- Procedure qui ajoute aux soldes actuelles les loyer pour un nouveau mois
-- IN (AUCUN): AUCUN
-- OUT (Aucun): AUCUN
-- ============================================
CREATE OR REPLACE PROCEDURE Gestion.p_soldeNouveauMois()
LANGUAGE PLPGSQL
AS $$
DECLARE
	-- DécLARE 
	v_CidBail Gestion.Baux.idBail%TYPE;
	v_Cloyer Gestion.Baux.loyer%TYPE;
	v_Clocataire Gestion.Locataires.idLocataire%TYPE;
	--Cursor sur tout les locataire possédant un bail actif
	cur_unLocataire CURSOR FOR
		SELECT b.idLocataire
		FROM Gestion.Baux b
		WHERE Gestion.f_bailActif(b.idBail) = TRUE;
		
BEGIN
	OPEN cur_unLocataire;
	LOOP
		FETCH cur_unLocataire INTO v_Clocataire;
		EXIT WHEN NOT FOUND;
		v_Cloyer := Gestion.f_getLoyer(v_Clocataire);
		--Ajuste le solde du locataire en ajoutant le loyer
		UPDATE Gestion.Locataires
		SET solde = solde + v_Cloyer
		WHERE idLocataire = v_Clocataire;
	END LOOP;
	CLOSE cur_unLocataire;
END;
$$;


-- ============================================
-- Fonction: f_locataireBailActif
-- Description:
-- Vérifie qu'avant un paiement, le locataire possède un bail TRIGGER
-- IN (): NEW
-- RETOUR (): NEW
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.f_locataireBailActif()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_bail Gestion.Baux.idBail%TYPE;
BEGIN
    -- Récupérer le bail du locataire
    v_bail := Gestion.f_getBail(NEW.idLocataire);

    -- Si aucun bail n'existe
    IF v_bail IS NULL THEN
        RAISE EXCEPTION 'Le locataire % ne possède pas de bail actif', NEW.idLocataire;
    END IF;

    -- Vérifier si le bail est actif
    IF Gestion.f_bailActif(v_bail) IS NOT TRUE THEN
        RAISE EXCEPTION 'Le locataire % ne possède pas de bail actif', NEW.idLocataire;
    END IF;

    RETURN NEW;
END;
$$;
--TRIGGER
CREATE OR REPLACE TRIGGER t_locataireBailActif
BEFORE INSERT
ON Gestion.PaiementsLocataire
FOR EACH ROW
EXECUTE FUNCTION Gestion.f_locataireBailActif();

-- ============================================
-- Fonction: f_updateSoldePaiment
-- Description:
-- Update le solde automatiquement suite à un paiement
-- IN (NEW): TRIGGER
-- RETOUR (): TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.f_updateSoldePaiement()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$

BEGIN
	-- Soustrait le montant du paiement au solde 
	UPDATE Gestion.Locataires
		SET solde = solde - NEW.montant
		WHERE idLocataire = NEW.idLocataire;
		
	RETURN NEW;
END;
$$;
--Trigger
CREATE OR REPLACE TRIGGER t_updateSoldePaiement
AFTER INSERT OR UPDATE
ON Gestion.PaiementsLocataire
FOR EACH ROW
EXECUTE FUNCTION Gestion.f_updateSoldePaiement();

-- ============================================
-- FUNCTION: f_genererProfitProprietaire()
-- Description:
-- Procedure génère les profit de chacun des propriétaires provenant des immeubles
-- IN (AUCUN): AUCUN
-- Retour : Table
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.f_genererProfitProprietaire(
    unePeriode Gestion.PaiementsLocataire.periode%TYPE
)
RETURNS TABLE(
	--Colonne de la table retourné
    idProprietaire INTEGER,
    CashFlow NUMERIC(10,2)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	RETURN QUERY
	--SELECT l'idPropriétaire et la somme des paiements sous le nom de la colonne cashflow
	SELECT p.idProprietaire, SUM(COALESCE(pl.montant,0.00)) AS CashFlow
	--Suite de jointure
		FROM Gestion.Proprietaires p
        JOIN Gestion.Immeubles i ON p.idProprietaire = i.idProprietaire
        JOIN Gestion.Logements l ON i.idImmeuble = l.idImmeuble
        JOIN Gestion.Locataires lo ON l.idLogement = lo.idLogement
        LEFT JOIN Gestion.PaiementsLocataire pl ON lo.idLocataire = pl.idLocataire
            AND pl.periode = unePeriode
	--Grouper et mis en ordre selon les ID de propriétaire
    GROUP BY p.idProprietaire
    ORDER BY p.idProprietaire ASC;

END;
$$;
	
-- ============================================
-- FONCTION: f_genererListeBaux()
-- Description:
-- Procedure génère la liste des baux actifs
-- IN (AUCUN): AUCUN
-- RETURN : Retourne une table
-- ============================================

CREATE OR REPLACE FUNCTION Gestion.f_liste_des_baux_solde()
RETURNS TABLE (
	--Colonnes de la table
    idProprietaire INTEGER,
    adresse VARCHAR(100),
    duree_du_bail VARCHAR(100),
    idBail INTEGER,
    locataire VARCHAR(100),
    numero_tel VARCHAR(11),
    loyer NUMERIC(10,2),
    modePaiement typePaiement,
    solde NUMERIC(10,2)
	)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
	 SELECT
			--Selectionne un propriétaire
			pro.idProprietaire,
			--L'adresse de l'immeuble
			Gestion.afficherAdresse(a.idAdresse) AS adresse,
			--La durée du bail
			Gestion.f_afficherDureeBail(b.idBail) AS duree_du_bail,
			--Le bail en question
			b.idBail,
			--Le nom du locataire associer au bail
			Gestion.afficherPrenomLocataire(loc.idLocataire) AS locataire,
			--Le numéro de téléphone du locataire (inconnu si le numéro est null)
			COALESCE(loc.noTelephone,'Inconnue')::VARCHAR(10) AS numero_tel,
			--Le loyer associé au bail
			b.loyer AS loyer,
			--Le mode de paiement du locataire
			loc.modePaiement,
			--Le solde du locataire (si null c'est 0.00)
			COALESCE(loc.solde,0) AS solde
			
		FROM Gestion.Proprietaires pro
		--Suite de jointure
			JOIN Gestion.Immeubles i ON pro.idProprietaire = i.idProprietaire
			JOIN Gestion.Adresses a ON i.idAdresse = a.idAdresse
			JOIN Gestion.Logements l ON i.idImmeuble = l.idImmeuble
			JOIN Gestion.Locataires loc ON l.idLogement = loc.idLogement
			JOIN Gestion.Baux b ON loc.idLocataire = b.idLocataire
		--Les bails doivent être actif
		WHERE Gestion.f_bailActif(b.idBail) = TRUE
		--Trié en ordre d'idPropriétaire et des dates de début des baux.
		ORDER BY pro.idProprietaire, b.dateDebut DESC;
END;
$$;
-- ============================================
-- FONCTION: f_afficherDureeBail()
-- Description:
-- Fonction qui permet de concaténé les dates d'un bail
-- IN (ENTIER): Un identifiant de bail
-- RETURN : Retourne la date sous forme de VARCHAR et concatene
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.f_afficherDureeBail
(
	unBail Gestion.Baux.idBail%TYPE
)
RETURNS VARCHAR(100)
LANGUAGE PLPGSQL
AS $$
DECLARE
--Déclaration des dates
	v_dateDebut DATE;
	v_dateFin DATE;
	v_dateAfficher VARCHAR(100);
BEGIN
	-- Récupérer la date de début et de fin
	SELECT dateDebut,dateFin
	INTO v_dateDebut,v_dateFin
	FROM Gestion.Baux
	WHERE idBail = unBail;
		-- Concaténé les deux dates
	v_dateAfficher :=(TO_CHAR(v_dateDebut,'YYYY-MM-DD')
					|| ' au ' ||
					TO_CHAR(v_dateFin,'YYYY-MM-DD'));
	RETURN v_dateAfficher;
END;
$$;

-- ============================================
-- FONCTION: f_afficherPrenomLocataire()
-- Description:
-- Fonction qui permet de concaténé le prénom et le nom d'un locataire
-- IN (ENTIER): Un identifiant de locataire
-- RETURN : Retourne le prenom et le nom du locataire sous forme de varchar concatene
-- ============================================
CREATE OR REPLACE FUNCTION Gestion.afficherPrenomLocataire
(
	unLocataire Gestion.Locataires.idLocataire%TYPE
)
RETURNS VARCHAR(100)
LANGUAGE PLPGSQL
AS $$
DECLARE
	--Déclaration de la valeur à afficher
	v_afficher VARCHAR(100);
BEGIN
	--Select le prénom et le concatene avec le nom
	SELECT prenom || ' ' || nom
    INTO v_afficher
    FROM Gestion.Locataires
    WHERE idLocataire = unLocataire;
	
	RETURN v_afficher;

END;
$$;
-- ============================================
-- FONCTION: f_afficherAdresse()
-- Description:
-- Fonction qui permet de concaténé une adresse
-- IN (ENTIER): Un identifiant d'adresse
-- RETURN : Retourne l'adresse sous forme de varchar concatene
-- ============================================

CREATE OR REPLACE FUNCTION Gestion.afficherAdresse
(
    unAdresse Gestion.Adresses.idAdresse%TYPE
) 
RETURNS VARCHAR(100)
LANGUAGE plpgsql
AS $$
DECLARE
	--Déclaration de la variable à afficher
    v_afficher VARCHAR(100);
BEGIN
	--Select les éléments de l'adresse et les concatenent ensemble
    SELECT (noCivique::VARCHAR || ' ' || rue || ', ' || ville || ' ' || codePostal)::VARCHAR(100)
    INTO v_afficher
    FROM Gestion.Adresses
    WHERE idAdresse = unAdresse;

    RETURN v_afficher;
END;
$$;

