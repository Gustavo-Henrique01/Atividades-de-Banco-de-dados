

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







 --1 ) Crie uma função que retorne os seguintes dados: nome do s jogadores, salário, idade em anos e
 --o nome da seleção onde o jogador joga. Atenção, a sua função deve receber o nome d a posição do
 --jogador como parâmetro e deve apresentar na saída somente dados referentes a est a posição.
 --Mostre como utilizar a função. Para implementar a função deste exercício é necessário estudar o
--comando: create type. Mostre como utilizar a função.

-- Criar um tipo composto para armazenar informações do jogador
create type jogador_info as (
    nome varchar(50),
    salario numeric(20,2),
    idade int,
    nome_selecao varchar(50)
);

create or replace function obter_dados_jogadores(
    posicao varchar(50)
)
returns setof jogador_info as $$
begin
    return query
    select
        jogador.nome,
        jogador.salario,
        extract(year from age(current_date, jogador.data_nascimento)) as idade,
        selecao.nome as nome_selecao
    from
        jogador
    join selecao on jogador.codigo_selecao = selecao.codigo
    where
        jogador.posicao = posicao;
end;
$$ language plpgsql;

SELECT * FROM obter_dados_jogadores('Atacante');


 --2 ) Crie uma função que retorne os seguintes dados: nome do s jogadores, salário, idade em anos e
-- o nome da seleção onde o jogador joga. Atenção, a sua função deve receber o nome d a posição do
-- jogador como parâmetro e deve apresentar na saída somente dados referentes a est a posição.
-- Mostre como utilizar a função. Para implementar a função deste exercício é necessário estudar o
-- comando: setof record .Mostre como utilizar a função.

-- Criar a função que retorna os dados específicos da posição usando SETOF RECORD
create or replace function obter_dados_jogadores_setof(
    posicao varchar(50)
)
returns setof record as $$
begin
    return query
    select
        jogador.nome,
        jogador.salario,
        extract(year from age(current_date, jogador.data_nascimento)) as idade,
        selecao.nome as nome_selecao
    from
        jogador
    join selecao on jogador.codigo_selecao = selecao.codigo
    where
        jogador.posicao = posicao;
end;
$$ language plpgsql;


SELECT * FROM obter_dados_jogadores_setof('Volante');

--3) Crie uma função que retorne os seguintes dados: nome do estádio, sua data de fundação, custo
--de construção, o nome das partidas neste estádio, a data das partidas e o nome dos torcedores que
--foram nas partidas. Atenção, a sua função deve receber um inteiro referente ao ano que aconteceu a
--partida e apresentar os dados somente após este ano. Para implementar a função deste exercício é
--necessário estudar os comandos: setof record ou create type. Mostre como utilizar a função.


create type estadio_info as (
    nome_estadio varchar(50),
    data_fundacao_estadio date,
    custo_construcao_estadio numeric(20,2),
    nome_partida varchar(50),
    data_partida timestamp,
    nome_torcedor varchar(50)
);

-- Criar a função que retorna os dados específicos do estádio
create or replace function obter_dados_estadio(
    ano_partida int
)
returns setof estadio_info as $$
begin
    return query
    select
        estadio.nome as nome_estadio,
        estadio.data_fundacao,
        estadio.custo_construcao,
        partida.nome as nome_partida,
        partida.data,
        torcedor.nome as nome_torcedor
    from
        estadio
    join partida on estadio.codigo = partida.codigo_estadio
    join estadio_torcedor on estadio.codigo = estadio_torcedor.codigo_estadio
    join torcedor on estadio_torcedor.codigo_torcedor = torcedor.codigo
    where
        extract(year from partida.data) > ano_partida;
end;
$$ language plpgsql;

SELECT * FROM obter_dados_estadio(2022);

---4) Crie uma função que retorne os seguintes dados: o nome das seleções e a média do salários de
--suas jogadoras. Mostre como utilizar a função. Para implementar a função deste exercício é
--necessário estudar os comandos: setof record ou create type. Mostre como utilizar a função.

-- Criar um tipo composto para armazenar informações da seleção e média salarial
create type selecao_media_salario as (
    nome_selecao varchar(50),
    media_salario numeric(20,2)
);

-- Criar a função que retorna a média de salários por seleção
create or replace function media_salarios_selecao()
returns setof selecao_media_salario as $$
begin
    return query
    select
        selecao.nome as nome_selecao,
        avg(jogador.salario) as media_salario
    from
        selecao
    join jogador on selecao.codigo = jogador.codigo_selecao
    group by
        selecao.nome;
end;
$$ language plpgsql;

SELECT * FROM media_salarios_selecao();


--5) Considere que as funções de agregação não existem na sua versão do SGBD, ou seja, não
--é permitido a sua utilização. Crie uma função que retorne a quantidade de jogadoras e o salário
--médio das jogadoras. Mostre como utilizar a função.
-- Criar um tipo composto para armazenar informações sobre a quantidade e a média de salários
create type info_jogadoras as (
    quantidade_jogadoras int,
    media_salario_jogadoras numeric(20,2)
);

-- Criar a função que retorna a quantidade de jogadoras e a média de salários
create or replace function quantidade_media_salarios_jogadoras()
returns info_jogadoras as $$
declare
    qtd_jogadoras int;
    media_salario numeric(20,2);
begin
 
    select count(*)
    into qtd_jogadoras
    from jogador;

 
    select avg(salario)
    into media_salario
    from jogador;

    return (qtd_jogadoras, media_salario);
end;
$$ language plpgsql;

SELECT * FROM quantidade_media_salarios_jogadoras();
