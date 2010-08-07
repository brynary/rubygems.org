class Dependency < ActiveRecord::Base
  belongs_to :rubygem
  belongs_to :version

  before_validation :use_gem_dependency,
                    :use_existing_rubygem,
                    :parse_gem_dependency
  validates_presence_of  :requirements
  validates_inclusion_of :scope, :in => %w( development runtime )

  scope :development, { :conditions => { :scope => 'development' }}
  scope :runtime,     { :conditions => { :scope => 'runtime'     }}

  attr_accessor :gem_dependency

  cattr_writer :allow_unknown

  def self.allow_unknown
    @@allow_unknown ||= false
  end

  def name
    rubygem.name
  end

  def payload
    {
      'name'         => name,
      'requirements' => requirements
    }
  end

  def as_json(options = {})
    payload
  end

  def to_xml(options = {})
    payload.to_xml(options.merge(:root => "dependency"))
  end

  private

  def use_gem_dependency
    if gem_dependency.class != Gem::Dependency
      errors.add :rubygem, "Please use Gem::Dependency to specify dependencies." 
      false
    end
  end

  def use_existing_rubygem
    return true if self.class.allow_unknown

    self.rubygem = Rubygem.find_by_name(gem_dependency.name)

    if rubygem.blank?
      errors[:base] << "Please specify dependencies that exist on #{I18n.t(:title)}: #{gem_dependency}"
      false
    end
  end

  def parse_gem_dependency
    self.requirements = gem_dependency.requirements_list.join(', ')
    self.scope = gem_dependency.type.to_s
  end
end
