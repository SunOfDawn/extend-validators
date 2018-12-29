require 'spec_helper'

class HashValidateable
  include ActiveModel::Validations
  validates :json_value, presence: true, hash: {
    [:first_name, :second_name] => { presence: true },
    age: { numericality: { only_integer: true, greater_than: 0 } },
    sex: { inclusion: { in: [1, 2] } },
    email: { format: { with: /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/ } },
    address: { length: { minimum: 5, maximum: 40, message: 'address not available length (5~40)' } },
    other: { hash: {
      birthday: { format: { with: /(\d{4}-\d{1,2}-\d{1,2})/ } },
      description: { allow_blank: true }
    } },
  }
  validates_hash_of :json_value, {
    age: { numericality: { only_integer: true, greater_than: 0 } },
    description: { format: { with: /.*/ }, allow_blank: true }
  }
  attr_accessor  :json_value
end

describe ActiveModel::Validations::HashValidator do
  subject { HashValidateable.new }
  let(:json) { { first_name: 'Melt',
                 second_name: 'Lilith',
                 age: 17,
                 sex: 2,
                 email: 'meltlilith@gmail.com',
                 address: 'sdhajkdjlkwjklqdjlkasdl',
                 other: { birthday: '1993-02-17', description: 'asdjklajdldlkajw' } } }

  context 'with valid json' do
    it 'is valid' do
      subject.json_value = json
      expect(subject).to be_valid
    end
  end

  context 'with null description' do
    it 'is valid' do
      subject.json_value = json
      subject.json_value[:other][:description] = ''
      expect(subject).to be_valid
    end
  end

  context 'with invalid json' do
    before { subject.json_value = json }

    context 'with invalid name' do
      before { subject.json_value[:first_name] = nil }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with invalid id' do
      before { subject.json_value[:age] = -1 }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with invalid sex' do
      before { subject.json_value[:sex] = 3 }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with invalid email' do
      before { subject.json_value[:email] = 'asdhjaksdjsa@ashdj.khda@s' }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with short address' do
      before { subject.json_value[:address] = 'asd' }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with long address' do
      before { subject.json_value[:address] = 'sajkldjaskldjoijdoiqwjdiojaslkdjqlwjdlkjqdjaoisdjoijqwdasdjkhqwjkdhjkashdkjhaskdj' }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with other json' do
      before { subject.json_value[:other] = 'asdsad' }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with other json' do
      before { subject.json_value[:other] = 'asdsad' }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with other birthday' do
      before { subject.json_value[:other][:birthday] = '2000-012-12' }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with invalid photo' do
      before { subject.json_value[:photo] = 'asdhaskjdkas' }
      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end
end