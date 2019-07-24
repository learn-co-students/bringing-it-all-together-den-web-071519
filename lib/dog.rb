class Dog
attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

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

  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL
    dog_data = DB[:conn].execute(sql, id)[0]
    new_dog = self.new_from_db(dog_data)
  end

  def self.find_or_create_by(hash)
    dog_query = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", hash[:name], hash[:breed])
    if !dog_query.empty?
      dog_data = dog_query[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(hash)
    end
    dog
  end

  def self.find_by_name(dog_name)
    dog_query = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?;", dog_name)[0]
    self.new_from_db(dog_query)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
