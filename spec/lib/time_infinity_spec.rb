require_relative '../spec_helper'
describe Chronos::TimeInfinity do

  context 'positive value' do
    let (:infinity) { Chronos::TimeInfinity.new }

    it 'is greater as an arbitrary Time value' do
      expect(infinity > Time.now).to be true
      expect(Time.now < infinity).to be true
    end

    it 'is greater equals an arbitrary Time value' do
      expect(infinity >= Time.now).to be true
      expect(Time.now <= infinity).to be true
    end

    it 'is not equals an arbitrary Time value' do
      expect(infinity == Time.now).to be false
      expect(Time.now == infinity).to be false
      expect(infinity != Time.now).to be true
      expect(Time.now != infinity).to be true
    end

    it 'is not smaller as an arbitrary Time value' do
      expect(infinity < Time.now).to be false
      expect(Time.now > infinity).to be false
    end

    it 'is not smaller equals an arbitrary Time value' do
      expect(infinity <= Time.now).to be false
      expect(Time.now >= infinity).to be false
    end

    it 'is equal another positive infinity' do
      expect(infinity).to eql Chronos::TimeInfinity.new
    end

    it 'is not equal to a negative infinity' do
      expect(infinity).not_to eql -Chronos::TimeInfinity.new
    end
  end

  context 'negative value' do
    let (:negative_infinity) { -Chronos::TimeInfinity.new }

    it 'is not greater as an arbitrary Time value' do
      expect(negative_infinity > Time.now).to be false
      expect(Time.now < negative_infinity).to be false
    end

    it 'is not greater equals an arbitrary Time value' do
      expect(negative_infinity >= Time.now).to be false
      expect(Time.now <= negative_infinity).to be false
    end

    it 'is not equals an arbitrary Time value' do
      expect(negative_infinity == Time.now).to be false
      expect(Time.now == negative_infinity).to be false
      expect(negative_infinity != Time.now).to be true
      expect(Time.now != negative_infinity).to be true
    end

    it 'is smaller as an arbitrary Time value' do
      expect(negative_infinity < Time.now).to be true
      expect(Time.now > negative_infinity).to be true
    end

    it 'is smaller equals an arbitrary Time value' do
      expect(negative_infinity <= Time.now).to be true
      expect(Time.now >= negative_infinity).to be true
    end

    it 'is equal another negative infinity' do
      expect(negative_infinity).to eql -Chronos::TimeInfinity.new
    end

    it 'is not equal to a positive infinity' do
      expect(negative_infinity).not_to eql Chronos::TimeInfinity.new
    end
  end
end
