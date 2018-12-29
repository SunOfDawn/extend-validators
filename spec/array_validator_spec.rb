require 'spec_helper'

class ArrayValidateable
  include ActiveModel::Validations
  validates :json_value, presence: true, array: {
    validates_each: { hash: {
      name: { presence: true },
      sub_list: { array: {
        validates_each: { inclusion: { in: [1, 2] } }
      }}
    }}, allow_nil: true
  }
  attr_accessor :json_value
end

describe ActiveModel::Validations::ArrayValidator do
  subject {ArrayValidateable.new}
  let(:array) {
    [
      { name: 'li', sub_list: [1, 1] },
      { name: 'wang', sub_list: [1, 2] }
    ]
  }

  context 'with valid json' do
    it 'is valid' do
      subject.json_value = array
      expect(subject).to be_valid
    end
  end

  context 'with invalid json' do
    before { subject.json_value = array }

    context 'with invalid name' do
      before { subject.json_value[0].delete(:name) }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with string sub_list value' do
      before { subject.json_value << 'asdjklwad' }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end

    context 'with invalid sub_list array value' do
      before { subject.json_value[0][:sub_list] << 3 }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end
end