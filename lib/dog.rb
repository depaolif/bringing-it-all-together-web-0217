require 'pry'

class Dog
	attr_accessor :name, :breed
	attr_reader :id

	def initialize(name:,breed:,id:nil)
		@name = name
		@breed = breed
		@id = id
	end
	
	def self.create_table
		sql =  <<-SQL
      		CREATE TABLE IF NOT EXISTS dogs (
	        id INTEGER PRIMARY KEY,
	        name TEXT,
	        breed TEXT
	        )
	    SQL
	    DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
			DROP TABLE IF EXISTS dogs
		SQL
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
			DB[:conn].execute(sql,self.name,self.breed)

			sql = <<-SQL
				SELECT * FROM dogs WHERE name = ? AND breed = ?
			SQL
			@id = DB[:conn].execute(sql,self.name,self.breed)[0][0]
		end
		self
	end

	def self.create(*args,**keyargs)
		dog = self.new(keyargs)
		dog.save
		dog
	end

	def self.find_by_id(id)
		sql = <<-SQL
			SELECT * FROM dogs WHERE id = ?
		SQL
		dog = DB[:conn].execute(sql,id)[0]
		self.new(id: dog[0], name: dog[1], breed:dog[2])
	end

	def self.find_or_create_by(*args,**keyargs)
		dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", keyargs[:name], keyargs[:breed])
	    if !dog.empty?
	      dog = self.find_by_id(dog[0][0])
	    else
	      dog = self.create(name: keyargs[:name], breed: keyargs[:breed])
	    end
	    dog
	end

	def self.new_from_db(dog)
		self.new(name: dog[1], breed: dog[2], id: dog[0])
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT id FROM dogs WHERE name = ?
		SQL
		dog_id = DB[:conn].execute(sql,name)[0][0]
		self.find_by_id(dog_id)
	end

	def update
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
		DB[:conn].execute(sql,self.name,self.breed,self.id)
	end
end