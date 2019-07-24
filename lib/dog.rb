class Dog
    attr_accessor :name, :breed, :id

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def self.create(name: name, breed: breed)
        dog = self.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = self.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map {|dog| self.new_from_db(dog)}.first
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map {|dog| self.new_from_db(dog)}.first
    end

    def self.find_or_create_by(name: name, breed: breed)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = self.new_from_db(dog_data)
        else
            dog = Dog.create(name: name, breed: breed)
        end
        dog
    end

    def initialize(name: name, breed: breed, id: id=nil)
        @name, @breed, @id = name, breed, id
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?;
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end
end