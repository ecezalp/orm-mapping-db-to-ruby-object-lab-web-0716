require 'pry'


class Student
  attr_accessor :id, :name, :grade

  @@ninth_grade = []
  @@below_12th = []

  def self.new_from_db(row)
    new_student = self.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM students;
    SQL
    all_students_unformatted = DB[:conn].execute(sql)
    all_students_unformatted.collect do |student_row|
      self.new_from_db(student_row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students name 
      WHERE name = ?;
    SQL
    found_student_row = DB[:conn].execute(sql, name)
    self.new_from_db(found_student_row[0])
  end

  def self.count_all_students_in_grade_9
    all.each do |student|
      if student.grade == "9"
        @@ninth_grade << student
      end
    end
    @@ninth_grade
  end
  
  def self.students_below_12th_grade
    all.each do |student|
      if student.grade != "12"
        @@below_12th << student
      end
    end
    @@below_12th
  end

  def self.first_x_students_in_grade_10(how_many)
    sql = <<-SQL
      SELECT * FROM students
      WHERE grade = 10
      ORDER BY id
      LIMIT ?;
    SQL
    DB[:conn].execute(sql, how_many)
  end

  def self.first_student_in_grade_10
    self.new_from_db(self.first_x_students_in_grade_10(1)[0])
  end

  def self.all_students_in_grade_X(grade_input)
    sql = <<-SQL
      SELECT * FROM students
      WHERE grade = ?;
    SQL
    DB[:conn].execute(sql, grade_input)
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
