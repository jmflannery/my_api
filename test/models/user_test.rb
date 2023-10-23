require "test_helper"

describe User do
  subject { FactoryBot.build(:user) }

  it 'should be valid' do
    expect(subject).must_be :valid?
  end

  it 'should not be valid without an email' do
    subject.email = nil
    expect(subject).wont_be :valid?
  end

  it 'should not be valid with a duplicated email' do
    FactoryBot.create(:user, email: subject.email)
    expect(subject).wont_be :valid?
  end

  it 'should not be valid without a password' do
    subject.password = nil
    expect(subject).wont_be :valid?
  end

  it 'should not be valid without a password_confirmation' do
    subject.password_confirmation = nil
    expect(subject).wont_be :valid?
  end

  it 'should not be valid if the password and password_confirmation do not match' do
    subject.password_confirmation = 'wrong answer'
    expect(subject).wont_be :valid?
  end
end
