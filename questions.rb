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

    def authored_questions
        Questions.find_by_author_id(self.id)
    end

    def authored_replies
        Replies.find_by_user_id(self.id)
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

    def self.find_by_author_id(author_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
        SELECT
        *
        FROM
        questions
        WHERE
        author_id = ?
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

      def author
        author_data =Users.find_by_id(self.author_id)
        puts "#{author_data.fname} #{author_data.lname}"
      end


      def replies
        Replies.find_by_question_id(self.id)
      end

end

class QuestionFollows
  attr_accessor :id, :user_id, :question_id
    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * from question_follows")
        data.map{|datum| QuestionFollows.new(datum)}
    end

    def self.followers_for_question_id(question_id)
      data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT 
        users. *
      FROM
        question_follows
      JOIN
        users ON question_follows.user_id = users.id
      WHERE
        question_id = ? 
      SQL

      data.map{|datum| Users.new(datum)}
    end

    def self.followed_questions_for_user_id(user_id)
      data = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT 
        questions. *
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        user_id = ? 
      SQL

      data.map{|datum| Questions.new(datum)}
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

class Replies
  attr_accessor :id, :question_id, :parent_reply_id, :author_id, :body
  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * from replies")
    data.map{|datum| Replies.new(datum)}
  end

  def self.find_by_id(id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, id)
        SELECT
        *
        FROM
        replies
        WHERE
        id = ?
    SQL
    return nil unless data.length > 0
    Replies.new(data.first)

  end

  def self.find_by_user_id(author_id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
        SELECT
        *
        FROM
        replies
        WHERE
        author_id = ?
    SQL
    return nil unless data.length > 0
    data.map{|datum| Replies.new(datum)}

  end

  def self.find_by_question_id(question_id)
    data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
        SELECT
        *
        FROM
        replies
        WHERE
        question_id = ?
    SQL
    return nil unless data.length > 0
    data.map{|datum| Replies.new(datum)}

  end

  def initialize(options)
      @id = options['id']
      @question_id = options['question_id']
      @parent_reply_id = options['parent_reply_id']
      @author_id = options['author_id']
      @body = options['body']
  end

  def create
        raise "#{self} already in database" if self.id
        QuestionsDBConnection.instance.execute(<<-SQL,self.question_id, self.parent_reply_id, self.author_id, self.body)
          INSERT INTO
            replies (question_id, parent_reply_id, author_id, body)
          VALUES
            (?, ?, ?, ?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
        raise "#{self} not in database" unless self.id
        QuestionsDBConnection.instance.execute(<<-SQL,self.question_id, self.parent_reply_id, self.author_id, self.body, self.id)
          UPDATE
            replies
          SET
            question_id = ?, parent_reply_id = ?, author_id = ?, body = ?
          WHERE
            id = ?
        SQL
  end

  def author
    author_data =Users.find_by_id(self.author_id)
    puts "#{author_data.fname} #{author_data.lname}"
  end

  def question
    Questions.find_by_id(self.question_id)
  end

  def parent_reply
    Replies.find_by_id(self.parent_reply_id)
  end

  def child_replies
    data = QuestionsDBConnection.instance.execute(<<-SQL, self.id)
      SELECT *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL
    #extract all replies that have that ID
    data.map {|datum| Replies.new(datum)}
  end


end

class QuestionLikes
  attr_accessor :id, :user_id, :question_id
    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * from question_likes")
        data.map{|datum| QuestionLikes.new(datum)}
    end

    def self.find_by_id(id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
            *
            FROM
            question_likes
            WHERE
            id = ?
        SQL
        return nil unless data.length > 0
        QuestionLikes.new(data.first)

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
          question_likes (user_id, question_id)
          VALUES
            (?, ?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
      end

      def update
        raise "#{self} not in database" unless self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.user_id, self.question_id, self.id)
          UPDATE
            question_likes
          SET
            user_id = ?, question_id = ?
          WHERE
            id = ?
        SQL
      end
end

class Tags
  attr_accessor :id, :name
    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * from tags")
        data.map{|datum| Tags.new(datum)}
    end

    def self.find_by_id(id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
            *
            FROM
            tags
            WHERE
            id = ?
        SQL
        return nil unless data.length > 0
        Tags.new(data.first)

    end

    def initialize(options)
        @id = options['id']
        @name = options['name']
    end

    def create
        raise "#{self} already in database" if self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.name)
          INSERT INTO
          tags (name)
          VALUES
            (?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
      end

      def update
        raise "#{self} not in database" unless self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.name, self.id)
          UPDATE
            tags
          SET
            name = ?
          WHERE
            id = ?
        SQL
      end
end


class QuestionTags
  attr_accessor :id, :question_id, :tag_id
    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * from question_tags")
        data.map{|datum| QuestionTags.new(datum)}
    end

    def self.find_by_id(id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
            *
            FROM
            question_tags
            WHERE
            id = ?
        SQL
        return nil unless data.length > 0
        QuestionTags.new(data.first)

    end

    def initialize(options)
        @id = options['id']
        @tag_id = options['tag_id']
        @question_id = options['question_id']
    end

    def create
        raise "#{self} already in database" if self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.question_id, self.tag_id)
          INSERT INTO
          question_tags (question_id, tag_id)
          VALUES
            (?, ?)
        SQL
        self.id = QuestionsDBConnection.instance.last_insert_row_id
      end

      def update
        raise "#{self} not in database" unless self.id
        QuestionsDBConnection.instance.execute(<<-SQL, self.question_id, self.tag_id, self.id)
          UPDATE
            question_tags
          SET
            question_id = ?, tag_id = ?
          WHERE
            id = ?
        SQL
      end
end
