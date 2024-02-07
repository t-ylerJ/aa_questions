require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Users
    attr_accessor :id, :fname, :lname

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * from users")
        data.map{|datum| Users.new(datum)}
    end

    def self.find_by_id(id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
            *
            FROM
            users
            WHERE
            id = ?
        SQL
        return nil unless data.length > 0
        Users.new(data.first)

    end

    def self.find_by_name(fname, lname)
        data = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
            SELECT
            *
            FROM
            users
            WHERE
            fname = ? AND lname = ?
        SQL
        return nil unless data.length > 0
        Users.new(data.first)

    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def create
        raise "#{self} already in database" if self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname)
          INSERT INTO
            users (fname, lname)
          VALUES
            (?, ?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
      end

      def update
        raise "#{self} not in database" unless self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.fname, self.lname, self.id)
          UPDATE
            users
          SET
            fname = ?, lname = ?
          WHERE
            id = ?
        SQL
      end

end

class Questions

    attr_accessor :id, :title, :body, :author_id

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * from questions")
        data.map{|datum| Questions.new(datum)}
    end

    def self.find_by_id(id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
            *
            FROM
            questions
            WHERE
            id = ?
        SQL
        return nil unless data.length > 0
        Questions.new(data.first)

    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end

    def create
        raise "#{self} already in database" if self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author_id)
          INSERT INTO
            questions (title, body, author_id)
          VALUES
            (?, ?, ?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
      end

      def update
        raise "#{self} not in database" unless self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.title, self.body, self.author_id, self.id)
          UPDATE
            questions
          SET
            title = ?, body = ?, author_id = ?
          WHERE
            id = ?
        SQL
      end

end

class QuestionFollows

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * from question_follows")
        data.map{|datum| QuestionFollows.new(datum)}
    end

    def self.find_by_id(id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
            *
            FROM
            question_follows
            WHERE
            id = ?
        SQL
        return nil unless data.length > 0
        QuestionFollows.new(data.first)

    end

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    def create
        raise "#{self} already in database" if self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.user_id, self.question_id)
          INSERT INTO
          question_follows (user_id, question_id)
          VALUES
            (?, ?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
      end

      def update
        raise "#{self} not in database" unless self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.user_id, self.question_id, self.id)
          UPDATE
            question_follows
          SET
            user_id = ?, question_id = ?
          WHERE
            id = ?
        SQL
      end

end
