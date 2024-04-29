
create type genero_enum as enum ('feminino', 'masculino', 'outros');
create table selecao(
	codigo serial not null, 
	nome varchar(50) not null, 
	pais varchar(50), 
	genero genero_enum,
	primary key(codigo)
);

insert into selecao(nome, pais, genero)
values('Brasileira', 'Brasil', 'feminino');
insert into selecao(nome, pais, genero)
values('Japonesa', 'Japão', 'feminino');
insert into selecao(nome, pais, genero)
values('Jamaicana', 'Jamaica', 'feminino');

select * from selecao;   
create table estadio(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	capacidade_maxima int, 
	custo_construcao numeric(20,2), 
	data_fundacao date
);

insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Maracanã', 78000, 5000000000, '1950-06-16');
insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Morenão', 45000, 1000000000, '1971-03-07');
insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Elias Gadia', 2500, 5000000, '1990-12-25');

create table jogador(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	data_nascimento date, 
	salario numeric(20,2), 
	time varchar(50), 
	posicao varchar(50), 
	codigo_selecao int,
	foreign key(codigo_selecao) references selecao(codigo)
);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Marta','1986-02-19', 2000000, 'Orlando', 'Atacante', 1);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Formiga','1978-03-03', 1000000, 'Santos', 'volante', 1);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Khalix','1992-08-26', 500000, 'Vasco', 'Goleira', 3);

create type fase_enum as enum ('grupo','oitavas', 'quartas', 'semi', 'final');

create table partida(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	data timestamp, 
	fase fase_enum, 
	valor_ingresso numeric(8,2), 
	quantidade_ingresso int, 
	codigo_estadio int references estadio(codigo),     
	codigo_selecao_a int references selecao(codigo), 
	codigo_selecao_b int references selecao(codigo)
);

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Final da Copa', '2023-08-20 06:00:00', 'final', 15000, 78000, 1, 1, 3);

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Disputa Terceiro Lugar', '2023-08-19 06:00:00', 'final', 5000, 2500, 3, 2, 3);

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Grupo A', '2023-07-24 06:00:00', 'grupo', 1000, 78000, 1, 1, 2);

create table torcedor(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	data_nascimento date, 
	renda numeric(20,2), 
	genero genero_enum, 
	codigo_selecao int references selecao(codigo)
);

insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Fulano', '1959-08-26', 2587416, 'masculino', 1);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Fulana', '1959-09-07', 2587416, 'feminino', 1);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Fulaninho', '1984-04-01', 2587416, 'masculino', 1);

create table estadio_torcedor(
	codigo_estadio int references estadio (codigo), 
	codigo_torcedor int references torcedor(codigo), 
	data timestamp,
	primary key(codigo_estadio, codigo_torcedor)
);

insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(1, 2, current_timestamp);
insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(3, 1, current_timestamp);
insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(2, 2, current_timestamp); 



--1) Crie uma view que tenha como saída: o nome das jogadoras, data de nascimento, idade em anos
--e o nome da seleção que cada uma joga. Considere que todas as datas devem sair no formato DD/
--MM/YYYY. Ordene a saída pela data de nascimento. Mostre como usar a view.

CREATE VIEW view_jogadoras AS
SELECT
j.nome AS nome_jogadora,
TO_CHAR(j.data_nascimento, 'DD/MM/YYYY') AS data_nascimento,
EXTRACT(YEAR FROM AGE(j.data_nascimento)) AS idade,
s.nome AS nome_selecao
FROM
jogador j
JOIN
selecao s ON j.codigo_selecao = s.codigo;

--2) Crie uma view que tenha como saída: o nome do estádio, tempo de fundação em dias do estádio,
--o nome das partidas e das seleções que jogaram a partida. Considere somente partidas do ano de
--2023. Mostre como usar a view.

CREATE VIEW view_estadio AS
SELECT
e.nome AS nome_estadio,
EXTRACT(day FROM (NOW() - e.data_fundacao)) AS "tempo_fundacao_em_dias",
p.nome AS nome_partida,
s.nome AS nome_selecao_a,
s2.nome AS nome_selecao_b
FROM
estadio e
JOIN
partida p ON e.codigo = p.codigo_estadio
JOIN
selecao s ON p.codigo_selecao_a = s.codigo
JOIN
selecao s2 ON p.codigo_selecao_b = s2.codigo
WHERE
EXTRACT(YEAR FROM p.data) = 2023;

select * from view_estadio ;


--3) Crie uma view que tenha como saída: Os dados das jogadoras que possuem salário acima da
--média dos salários das jogadoras que nasceram entre o ano de 2000 e 2009. Mostre como usar a
---view.

create  view dados_jogadoras_salario_acima_da_media as
select j.nome
from jogador j
where j.salario > (select avg(j1.salario) from jogador j1) and  extract(year from(j.data_nascimento)) BETWEEN 2000 AND 2009;
SELECT * FROM dados_jogadoras_salario_acima_da_media;

--4) Crie uma view que tenha como saída: A quantidade de torcedores nascidos por ano e a média da
--renda destes torcedores. Arredonde a média em duas casas decimais. Ordene pelo ano a saída.
--Mostre como usar a view

create view torcedor_nascido_ano_e_renda as
select 
extract (year from data_nascimento) as nascimento_ano,
count (*) as quantidade_torcedores,
trunc(avg(renda),2) as media_renda
from torcedor
group by  nascimento_ano
order by nascimento_ano;

select * from 
torcedor_nascido_ano_e_renda ;

--5) Crie uma view que tenha como saída: O nome das jogadoras e das partidas que cada uma
--disputou. Ordene pelo nome das jogadoras. Mostre como usar a view.

create view nome_jogadoras_partidas_disputou as
select jo.nome as nome_jogadora ,p.nome as nome_partida
from jogador jo
join selecao s on jo.codigo_selecao = s.codigo
join partida p on s.codigo = p.codigo_selecao_a or  s.codigo = p.codigo_selecao_b
order by jo.nome ;

select * from nome_jogadoras_partidas_disputou ;

--6) Remova a view criada no exercício dois
DROP view view_estadio ;