require_relative '../spec_helper'
describe Chronos::TimeLog do
  it 'blubs' do
    expect(create(:user)).to be_valid
  end
  it 'has a valid factory' do
    expect(create(:time_log)).to be_valid
  end
  it 'is invalid without a user'
  it 'is invalid without a start time'
  it 'is invalid without a stop time'
  it 'is only valid with stop time greater than start time'
end