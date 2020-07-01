\c

CREATE TABLE teams (
    id serial PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    position integer NOT NULL
);

INSERT INTO teams (name, position)
VALUES
    ('AG2R La Mondiale', 1),
    ('EF Education First–Drapac p/b Cannondale', 2),
    ('BMC Racing Team', 3),
    ('Team Dimension Data', 4),
    ('Bahrain–Merida', 5),
    ('Team Katusha–Alpecin', 6),
    ('Bora–Hansgrohe', 7),
    ('Astana', 8);