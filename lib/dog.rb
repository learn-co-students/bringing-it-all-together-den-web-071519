require 'pry'
class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id, @name, @breed = id, name, breed
        # binding.pry
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
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

    def self.create(hash)
        new_dog = Dog.new(hash)
        new_dog.save
        new_dog
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? and breed = ? LIMIT 1"
        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new_from_db(dog_data)
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        dog_query = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name).flatten
        self.new_from_db(dog_query) 
    end

    def self.find_by_id(id)
        dog_query = DB[:conn].execute(("SELECT * FROM dogs WHERE id = ? LIMIT 1"), id).flatten
        self.new_from_db(dog_query)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
# binding.pry
end
