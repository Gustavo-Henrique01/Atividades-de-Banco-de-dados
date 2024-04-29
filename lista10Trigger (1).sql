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




---1) Crie uma trigger com a seguinte regra: Não é permitido aumento para os salários das jogadoras.

CREATE OR REPLACE FUNCTION bloquear_aumento_salario()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o jogador está em uma seleção com gênero feminino
    IF (SELECT genero FROM selecao WHERE codigo = NEW.codigo_selecao) = 'feminino' THEN
        -- Se o novo salário for maior que o antigo, impede o aumento
        IF NEW.salario > OLD.salario THEN
            RAISE EXCEPTION 'Aumento de salário não permitido para jogadoras.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_bloquear_aumento_salario
BEFORE UPDATE ON jogador
FOR EACH ROW
EXECUTE FUNCTION bloquear_aumento_salario();


-- criação da trigger

CREATE TRIGGER salario BEFORE  UPDATE on jogador 
FOR EACH ROW EXECUTE PROCEDURE atualizaSalario();


UPDATE jogador j
SET salario = 300000000000
FROM selecao s
WHERE j.codigo_selecao = s.codigo
  AND s.genero = 'feminino';
--para testar 



---2) Crie uma trigger com a seguinte regra: Ao inserir uma partida, caso o valor do ingresso seja maior
--que o maior valor do ingresso das partidas já cadastradas, atualize o valor do ingresso para 75% do
--maior valor do ingresso das partidas.

create or replace function atualizar_valor_ingresso()
returns trigger as $$
declare
    max_valor_ingresso numeric(8,2);
begin
    -- Encontra o maior valor de ingresso entre as partidas existentes
    select max(valor_ingresso) into max_valor_ingresso
    from partida;

    -- Se o valor de ingresso da nova partida for maior, atualiza para 75% do maior valor
    if new.valor_ingresso > max_valor_ingresso then
        new.valor_ingresso := max_valor_ingresso * 0.75;
    end if;

    return new;
end;
$$ language plpgsql;

create trigger trigger_atualizar_valor_ingresso
before insert on partida
for each row
execute function atualizar_valor_ingresso();

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Copa', '2023-08-20 06:00:00', 'final', 20000, 78000, 1, 1, 3);

select  valor_ingresso from  partida ;

---3) Crie uma trigger com a seguinte regra: Ao excluir um torcedor, tudo que é vinculado ao torcedor
--deve ser excluído antes.

create or replace function excluir_torcedor_e_vinculos()
returns trigger as $$
begin
    delete from estadio_torcedor where codigo_torcedor = old.codigo;
    -- Adicione aqui outras exclusões necessárias relacionadas ao torcedor
    return old;
end;
$$ language plpgsql;

create trigger trigger_excluir_torcedor
before delete on torcedor
for each row
execute function excluir_torcedor_e_vinculos();


---4) Crie uma trigger com a seguinte regra: Ao excluir um estádio, tudo que é vinculado ao estádio
--deve ser excluído antes.

create or replace function excluir_estadio_e_vinculos()
returns trigger as $$
begin
    delete from estadio_torcedor where codigo_estadio = old.codigo;
    -- Adicione aqui outras exclusões necessárias relacionadas ao estádio
    return old;
end;
$$ language plpgsql;

create trigger trigger_excluir_estadio
before delete on estadio
for each row
execute function excluir_estadio_e_vinculos();



---5) Crie uma trigger com a seguinte regra: Antes de remover uma seleção, tudo que é vinculado a
--seleção deve ser transferido para a seleção brasileira.

create or replace function transferir_vinculos_para_selecao_brasileira()
returns trigger as $$
begin
    -- Transfira os vínculos para a seleção brasileira
    update tabela set codigo_selecao = (select codigo from selecao where nome = 'Brasileira') where codigo_selecao = old.codigo;
    -- Adicione aqui outras transferências necessárias relacionadas à seleção
    return old;
end;
$$ language plpgsql;

create trigger trigger_transferir_vinculos
before delete on selecao
for each row
execute function transferir_vinculos_para_selecao_brasileira();



--6) Modifique a trigger do exercício número dois para atender a seguinte regra: Ao modificar uma
--partida (inserir ou atualizar os dados), caso o valor do ingresso seja maior que o maior valor do
--ingresso das partidas já cadastradas, atualize o valor do ingresso para 75% do maior valor do
--ingresso das partidas.

create or replace function atualizar_valor_ingresso()
returns trigger as $$
declare
    max_valor_ingresso numeric(8,2);
begin
    -- Encontra o maior valor de ingresso entre as partidas existentes
    select max(valor_ingresso) into max_valor_ingresso
    from partida;

    -- Se o valor de ingresso da nova/atualizada partida for maior, atualiza para 75% do maior valor
    if new.valor_ingresso > max_valor_ingresso then
        new.valor_ingresso := max_valor_ingresso * 0.75;
    end if;

    return new;
end;
$$ language plpgsql;

create trigger trigger_atualizar_valor_ingresso
before insert or update on partida
for each row
execute function atualizar_valor_ingresso();


--7) Crie uma trigger com a seguinte regra: Jogadoras nascidas antes do ano de 1995 não podem ser
--cadastradas.

create or replace function impedir_cadastro_jogadora()
returns trigger as $$
begin
    if extract(year from new.data_nascimento) < 1995 then
        raise exception 'Jogadoras nascidas antes de 1995 não podem ser cadastradas.';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trigger_impedir_cadastro_jogadora
before insert on jogador
for each row
execute function impedir_cadastro_jogadora();
