-- schema da usare in tutto il file
use banca;

-- [1] ETA
-- ---------------------------------------------------------------------------------------------------------------
create temporary table clienti_eta as
select
	id_cliente,
	year(current_date()) - year(data_nascita) - 
		case
			when month(current_date) < month(data_nascita) then 1
			when month(current_date) = month(data_nascita) and day(current_date) < day(data_nascita) then 1
			else 0
        end as eta
from cliente



-- USCITA
-- [2] Numero di transazioni in uscita su tutti i conti 
-- [4] Importo transato in uscita su tutti i conti 
-- [8] Numero di transazioni in uscita per tipologia (un indicatore per tipo) 
-- [10] Importo transato in uscita per tipologia di conto (un indicatore per tipo) 
-- ---------------------------------------------------------------------------------------------------------------
create temporary table uscita as
select
	con.id_cliente,
    count(*) n_trans_uscita,
    sum(tra.importo) importo_uscita,
    count(case when tra.id_tipo_trans = 3 then 1 else null end) n_trans_uscita_amazon,
    count(case when tra.id_tipo_trans = 4 then 1 else null end) n_trans_uscita_mutuo,
    count(case when tra.id_tipo_trans = 5 then 1 else null end) n_trans_uscita_hotel,
    count(case when tra.id_tipo_trans = 6 then 1 else null end) n_trans_uscita_aereo,
    count(case when tra.id_tipo_trans = 7 then 1 else null end) n_trans_uscita_supermercato,
    sum(case when con.id_tipo_conto = 0 then tra.importo else 0 end) importo_uscita_conto_base,
    sum(case when con.id_tipo_conto = 1 then tra.importo else 0 end) importo_uscita_conto_business,
    sum(case when con.id_tipo_conto = 2 then tra.importo else 0 end) importo_uscita_conto_privati,
    sum(case when con.id_tipo_conto = 3 then tra.importo else 0 end) importo_uscita_conto_famiglie
from
	conto con
	inner join transazioni tra on con.id_conto = tra.id_conto
	inner join tipo_transazione t_tra on tra.id_tipo_trans = t_tra.id_tipo_transazione
where
	t_tra.segno = '-'
group by
	con.id_cliente

 

-- ENTRATA
-- [3] Numero di transazioni in entrata su tutti i conti
-- [5] Importo transato in entrata su tutti i conti 
-- [9] Numero di transazioni in entrata per tipologia (un indicatore per tipo) 
-- [11] Importo transato in entrata per tipologia di conto (un indicatore per tipo) 
-- ---------------------------------------------------------------------------------------------------------------
create temporary table entrata as
select
	con.id_cliente,
    count(*) n_trans_entrata,
    sum(tra.importo) importo_entrata,
    count(case when tra.id_tipo_trans = 0 then 1 else null end) n_trans_entrata_stipendio,
    count(case when tra.id_tipo_trans = 1 then 1 else null end) n_trans_entrata_pensione,
    count(case when tra.id_tipo_trans = 2 then 1 else null end) n_trans_entrata_dividendi,
    sum(case when con.id_tipo_conto = 0 then tra.importo else 0 end) importo_entrata_conto_base,
    sum(case when con.id_tipo_conto = 1 then tra.importo else 0 end) importo_entrata_conto_business,
    sum(case when con.id_tipo_conto = 2 then tra.importo else 0 end) importo_entrata_conto_privati,
    sum(case when con.id_tipo_conto = 3 then tra.importo else 0 end) importo_entrata_conto_famiglie
from
	conto con
	inner join transazioni tra on con.id_conto = tra.id_conto
	inner join tipo_transazione t_tra on tra.id_tipo_trans = t_tra.id_tipo_transazione
where
	t_tra.segno = '+'
group by
	con.id_cliente
    
    
    
-- CONTI
-- [6] Numero totale di conti posseduti
-- [7] Numero di conti posseduti per tipologia (un indicatore per tipo)
-- ---------------------------------------------------------------------------------------------------------------
create temporary table conti as
select
	con.id_cliente,
    count(*) n_conti,
    sum(case when con.id_tipo_conto = 0 then 1 else 0 end) n_conti_base,
    sum(case when con.id_tipo_conto = 1 then 1 else 0 end) n_conti_business,
    sum(case when con.id_tipo_conto = 2 then 1 else 0 end) n_conti_privati,
    sum(case when con.id_tipo_conto = 3 then 1 else 0 end) n_conti_famiglie
from
	conto con
group by
	con.id_cliente




-- TABELLA FINALE  -----------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------
select
	cli_e.id_cliente,
    cli_e.eta,
    
    coalesce(usc.n_trans_uscita, 0) n_trans_uscita,
    coalesce(ent.n_trans_entrata, 0) n_trans_entrata,
    
    coalesce(usc.importo_uscita, 0) importo_uscita,
    coalesce(ent.importo_entrata, 0) importo_entrata,
    
    coalesce(con.n_conti, 0) n_conti,
    coalesce(con.n_conti_base, 0) n_conti_base,
    coalesce(con.n_conti_business, 0) n_conti_business,
    coalesce(con.n_conti_privati, 0) n_conti_privati,
    coalesce(con.n_conti_famiglie, 0) n_conti_famiglie,

    coalesce(usc.n_trans_uscita_amazon, 0) n_trans_uscita_amazon,
    coalesce(usc.n_trans_uscita_mutuo, 0) n_trans_uscita_mutuo,
    coalesce(usc.n_trans_uscita_hotel, 0) n_trans_uscita_hotel,
    coalesce(usc.n_trans_uscita_aereo, 0) n_trans_uscita_aereo,
    coalesce(usc.n_trans_uscita_supermercato, 0) n_trans_uscita_supermercato,
    
    coalesce(ent.n_trans_entrata_stipendio, 0) n_trans_entrata_stipendio,
    coalesce(ent.n_trans_entrata_pensione, 0) n_trans_entrata_pensione,
    coalesce(ent.n_trans_entrata_dividendi, 0) n_trans_entrata_dividendi,
    
    coalesce(usc.importo_uscita_conto_base, 0) importo_uscita_conto_base,
    coalesce(usc.importo_uscita_conto_business, 0) importo_uscita_conto_business,
    coalesce(usc.importo_uscita_conto_privati, 0) importo_uscita_conto_privati,
    coalesce(usc.importo_uscita_conto_famiglie, 0) importo_uscita_conto_famiglie,

    coalesce(ent.importo_entrata_conto_base, 0) importo_entrata_conto_base,
    coalesce(ent.importo_entrata_conto_business, 0) importo_entrata_conto_business,
    coalesce(ent.importo_entrata_conto_privati, 0) importo_entrata_conto_privati,
    coalesce(ent.importo_entrata_conto_famiglie, 0) importo_entrata_conto_famiglie
from
	clienti_eta cli_e
    left join uscita usc on cli_e.id_cliente = usc.id_cliente
    left join entrata ent on cli_e.id_cliente = ent.id_cliente
    left join conti con on cli_e.id_cliente = con.id_cliente
order by
	cli_e.id_cliente asc