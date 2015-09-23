describe Wprapper::Author do
  describe '.find' do
    let(:user_identifier) { '4' }

    it 'should fetch the user profile', :vcr do
      wp_author = Wprapper::Author.find(user_identifier)

      expect(wp_author.identifier).to eql(user_identifier)
      expect(wp_author.display_name).to eql('Liz')
      expect(wp_author.email).to eql('qpoliticalliz@gmail.com')
    end
  end
end