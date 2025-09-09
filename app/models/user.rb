class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Relacionamentos
  has_many :clients, dependent: :destroy
  has_many :foods, dependent: :destroy
  has_many :diets, dependent: :destroy

  # Validações
  validates :name, presence: true
  validates :phone, presence: true
end
