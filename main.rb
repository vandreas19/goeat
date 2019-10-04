require "rubygems"
require "thor"
class GoEat < Thor
    @@driver,@@checkdriver = [], []
    @@store,@@checkstore = [], []
    @@user, @@checkuser = [], []
    @@nama_driver = ["Joe", "Andar", "Winner", "Sumihar", "Amsal"]
    @@rated_driver = []
    @@store_eq = []
    @@nama_store = ["Mak Roby", "Mak Atur", "Mak Sarah"]
    @@barang_store = [{"Mie Kuning" => 6000, "Pecel Lele" => 18000},{"Indomie Goreng" => 12000, "Ifumie Goreng"=> 8000},{"Capcai Spesial"=>20000, "Lontong Sayur"=> 15000}]
    @@counter, @@res = 0,0
    @@detail_order= []
    @@unit_cost, @@unit_distance = 0,0
    desc "showmap", "showmap"
    long_desc <<-LONGDESC
     show 20 * 20 map with 3 random driver and random 5 store,
     driver is mark as "%", store is mark as "@" and user mark as U
    LONGDESC
    def showmap
        puts "---------------- MAP ----------------"
        px = 0
        @@user << rand(1..400)
        until px == 5
            x = rand(1..400)
            unless @@user.include?x
                unless @@driver.include?x
                    @@driver << x
                    px += 1
                end
            end
        end
        until @@counter == 3
            x = rand(1..400)
            unless @@driver.include?x
                unless @@user.include?x
                    unless @@store.include?x
                        @@store << x
                        @@counter += 1
                    end
                end
            end
        end
        for i in @@driver
            left = i / 20
            right = i % 20
            if right == 0
                temp = [left-1 , 19]
            else
                temp = [left, right-1]
            end
            @@checkdriver << temp
        end
        for i in 1..5
            @@rated_driver << [@@checkdriver[i-1], @@nama_driver[i-1], 0]
        end
        for i in @@store
            left = i / 20
            right = i % 20
            if right == 0
                temp = [left-1 , 19]
            else
                temp = [left, right-1]
            end
            @@checkstore << temp
        end

        for i in 1..3
            @@store_eq << [@@checkstore[i-1], @@nama_store[i-1], @@barang_store[i-1]]
        end

        uleft = @@user.first / 20 
        uright = @@user.first % 20

        if uright == 0
            @@checkuser = [uleft-1, 19]
        else
            @@checkuser = [uleft, uright-1]
        end

        list = []
        for i in 1..400
            if @@driver.include?i
                list << '%'
            elsif @@store.include?i
                list << '@'
            elsif @@user.include?i
                list << 'U'
            else list << '*'
            end
        end
        puts
       #print checkdriver , checkstore, checkuser
        for i in 1..20
            print "\t"
            for j in 1..20
              @@res += 1
              print list[@@res-1]
            end
            puts
        end

        puts "\n----------------------- DRIVER---------------------------"
        print "\t\tNama Driver:\n"
        @@rated_driver.each{
            |i| puts "\t\t#{i[1]}"
        }

        puts "\n----------------------- STORE----------------------------"
        print "\t\tNama Toko\n"
        
        @@store_eq.each{
            |i| puts "\t\t#{i[1]}"
        }

        input = ask("Pilih Nama Toko : ")
        pilihan = @@store_eq.select{|i|  i[1] == input}[0]
        
        puts "\n----------------------DESKRIPSI TOKO-------------------------"
        puts "\t\tNama Toko:\t#{pilihan[1]}"
        puts
        puts "\t\tLokasi Toko:\t#{pilihan[0]}"
        puts
        puts "\t\tDaftar Makanan\n"
        puts "\t\tNama\tHarga"
        pilihan[2].each{
            |i,j| puts "\t\t#{i}\t#{j}"
        }

        ch = ask("Mau Mesan?(Ya/Tidak)")
        temp_pesanan = {}
        while ch != "Tidak"
            makanan = ask("Pilih Menu yang Tersedia di #{pilihan[1]}\n")
            jumlah_pesanan = ask("Masukkan Jumlah\n").to_i
            harga = pilihan[2][makanan] * jumlah_pesanan
            @@unit_cost += harga
            temp_pesanan[makanan] = jumlah_pesanan
            ch = ask("Lagi?(Ya/Tidak)")
        end
        
        #cari driver yang paling dekat ke user
        #change
        jarak_driver_to_user = 10000 #
        jarak_toko_to_user = 0
        for i in @@rated_driver
            jarak = (i[0][0] - @@checkuser[0]).abs + (i[0][1] - @@checkuser[1]).abs
            if jarak < jarak_driver_to_user
                jarak_driver_to_user = jarak
                ##jarak_driver_to_toko = (i[0][0] - pilihan[0][0]).abs + (i[0][1] - pilihan[0][1]).abs
                jarak_toko_to_user = (@@checkuser[0] - pilihan[0][0]).abs + (@@checkuser[1] - pilihan[0][1]).abs
                temp_lokasi_driver = i[0]
            end
        end

        #unit_distance = jarak user ke toko
        @@unit_distance = jarak_toko_to_user
        @@detail_order << [pilihan[1], temp_pesanan, (@@unit_cost * @@unit_distance)]
        
        if temp_pesanan.length > 0
            #route
            #driver ke toko :)
            puts "driver is on the way to store, start at (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
            if pilihan[0][0] > temp_lokasi_driver[0]
                while temp_lokasi_driver[0] < pilihan[0][0]
                    temp_lokasi_driver[0] += 1
                    break if temp_lokasi_driver[0] == pilihan[0][0]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                end
            else
                while temp_lokasi_driver[0] > pilihan[0][0]
                    temp_lokasi_driver[0] -= 1
                    break if temp_lokasi_driver[0] == pilihan[0][0]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                end
            end

            if pilihan[0][1] > temp_lokasi_driver[1]
                until temp_lokasi_driver[1] == pilihan[0][1]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                    temp_lokasi_driver[1] += 1
                end
                puts "go to (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]}), driver arrived at the store!"
            else
                until temp_lokasi_driver[1] == pilihan[0][1]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                    temp_lokasi_driver[1] -= 1
                end
                puts "go to (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]}), driver arrived at the store!"
            end

            #driver ke user :)
            puts "driver has Bought the item(s), start at (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
            if @@checkuser[0] > temp_lokasi_driver[0]
                while temp_lokasi_driver[0] < @@checkuser[0]
                    temp_lokasi_driver[0] += 1
                    break if temp_lokasi_driver[0] == @@checkuser[0]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                end
            else
                while temp_lokasi_driver[0] > @@checkuser[0]
                    temp_lokasi_driver[0] -= 1
                    break if temp_lokasi_driver[0] == @@checkuser[0]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                end
            end

            if @@checkuser[1] > temp_lokasi_driver[1]
                until temp_lokasi_driver[1] == @@checkuser[1]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                    temp_lokasi_driver[1] += 1
                end
                puts "go to (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]}), driver arrived at your place!"
            else
                until temp_lokasi_driver[1] == @@checkuser[1]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                    temp_lokasi_driver[1] -= 1
                end
                puts "go to (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]}), driver arrived at your place!"
            end
            #beri rating :)
            x = @@rated_driver.select{
                |i| i[0] == temp_lokasi_driver
            }[0]
            puts "\n\n\n"
            rating = ask("Beri Rating Untuk Driver #{x[1]} (1 - 5)").to_i
            @@rated_driver[@@rated_driver.index(x)][2] += rating
        end

        his = ask("Wanna View History:(Ya/Tidak)")
        if his == "Ya"
            History()
        end
        File.open("Driver.txt", "w"){
            |file| 
            file.puts("\t\tNama Driver\t\tRating")
            for i in @@rated_driver
                file.puts("\t\t#{i[1]}\t\t#{i[2]}")
            end
        }

    end

    desc "showmapbyargument", "show map with 3 arguments"
    long_desc <<-LONGDESC
    show map with 3 argument n, x , and y where x is size of map, x and y
    is user coordinate
    LONGDESC
    def showmapbyargument(n, x, y)
        puts "---------------- MAP ----------------"
        n,x,y = n.to_i, x.to_i, y.to_i
        users, checkusers = [(x *n) + y + 1],[x,y]
        mul = n.to_i ** 2
        px = 0
        until px == 5
            x = rand(1..mul)
            unless users.include?x
                unless @@driver.include?x
                    @@driver << x
                    px += 1
                end
            end
        end

        until @@counter == 3
            x = rand(1..mul)
            unless @@driver.include?x
                 unless users.include?x
                    unless @@store.include?x
                        @@store << x
                        @@counter += 1
                    end
                end
            end
        end
        for i in @@driver
            left = i / n
            right = i % n
            if right == 0
                temp = [left-1 , n-1]
            else
                temp = [left, right-1]
            end
            @@checkdriver << temp
        end
        for i in 1..5
            @@rated_driver << [@@checkdriver[i-1], @@nama_driver[i-1], 0]
        end
        for i in @@store
            left = i / n
            right = i % n
            if right == 0
                temp = [left-1 , n-1]
            else
                temp = [left, right-1]
            end
            @@checkstore << temp
        end
        for i in 1..3
            @@store_eq << [@@checkstore[i-1], @@nama_store[i-1], @@barang_store[i-1]]
        end

        list = []
        for i in 1..mul
            if @@driver.include?i
                list << '%'
            elsif @@store.include?i
                list << '@'
            elsif users.include?i
                list << 'U'
            else list << '*'
            end
        end
        puts
        for i in 1..n
            print "\t"
            for j in 1..n
              @@res += 1
              print list[@@res-1]
            end
            puts
        end
        puts "\n----------------------- DRIVER---------------------------"
        print "\t\tNama Driver:\n"
        @@rated_driver.each{
            |i| puts "\t\t#{i[1]}"
        }
        puts "\n----------------------- STORE----------------------------"
        print "\t\tNama Toko\n"
        
        @@store_eq.each{
            |i| puts "\t\t#{i[1]}"
        }
        input = ask("Pilih Nama Toko : ")
        pilihan = @@store_eq.select{|i|  i[1] == input}[0]
        
        puts "\n----------------------DESKRIPSI TOKO-------------------------"
        puts "\t\tNama Toko:\t#{pilihan[1]}"
        puts
        puts "\t\tLokasi Toko:\t#{pilihan[0]}"
        puts
        puts "\t\tDaftar Makanan\n"
        puts "\t\tNama\tHarga"
        pilihan[2].each{
            |i,j| puts "\t\t#{i}\t#{j}"
        }
        ch = ask("Mau Mesan?(Ya/Tidak)")
        temp_pesanan = {}
        while ch != "Tidak"
            makanan = ask("Pilih Menu yang Tersedia di #{pilihan[1]}\n")
            jumlah_pesanan = ask("Masukkan Jumlah\n").to_i
            harga = pilihan[2][makanan] * jumlah_pesanan
            @@unit_cost += harga
            temp_pesanan[makanan] = jumlah_pesanan
            ch = ask("Lagi?(Ya/Tidak)")
        end
        #
        #cari driver yang paling dekat ke user
        jarak_driver_to_user = 10000 #
        jarak_toko_to_user = 0
        for i in @@rated_driver
            jarak = (i[0][0] - checkusers[0]).abs + (i[0][1] - checkusers[1]).abs
            if jarak < jarak_driver_to_user
                jarak_driver_to_user = jarak
                ##jarak_driver_to_toko = (i[0][0] - pilihan[0][0]).abs + (i[0][1] - pilihan[0][1]).abs
                jarak_toko_to_user = (checkusers[0] - pilihan[0][0]).abs + (checkusers[1] - pilihan[0][1]).abs
                temp_lokasi_driver = i[0]
            end
        end

        #unit_distance = jarak user ke toko
        @@unit_distance = jarak_toko_to_user
        @@detail_order << [pilihan[1], temp_pesanan, (@@unit_cost * @@unit_distance)]
        
        if temp_pesanan.length > 0
            #route
            #driver ke toko :)
            puts "driver is on the way to store, start at (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
            if pilihan[0][0] > temp_lokasi_driver[0]
                while temp_lokasi_driver[0] < pilihan[0][0]
                    temp_lokasi_driver[0] += 1
                    break if temp_lokasi_driver[0] == pilihan[0][0]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                end
            else
                while temp_lokasi_driver[0] > pilihan[0][0]
                    temp_lokasi_driver[0] -= 1
                    break if temp_lokasi_driver[0] == pilihan[0][0]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                end
            end

            if pilihan[0][1] > temp_lokasi_driver[1]
                until temp_lokasi_driver[1] == pilihan[0][1]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                    temp_lokasi_driver[1] += 1
                end
                puts "go to (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]}), driver arrived at the store!"
            else
                until temp_lokasi_driver[1] == pilihan[0][1]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                    temp_lokasi_driver[1] -= 1
                end
                puts "go to (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]}), driver arrived at the store!"
            end

            #driver ke user :)
            puts "driver has Bought the item(s), start at (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
            if checkusers[0] > temp_lokasi_driver[0]
                while temp_lokasi_driver[0] < checkusers[0]
                    temp_lokasi_driver[0] += 1
                    break if temp_lokasi_driver[0] == checkusers[0]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                end
            else
                while temp_lokasi_driver[0] > checkusers[0]
                    temp_lokasi_driver[0] -= 1
                    break if temp_lokasi_driver[0] == checkusers[0]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                end
            end

            if checkusers[1] > temp_lokasi_driver[1]
                until temp_lokasi_driver[1] == checkusers[1]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                    temp_lokasi_driver[1] += 1
                end
                puts "go to (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]}), driver arrived at your place!"
            else
                until temp_lokasi_driver[1] == checkusers[1]
                    puts "go to(#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]})"
                    temp_lokasi_driver[1] -= 1
                end
                puts "go to (#{temp_lokasi_driver[0]},#{temp_lokasi_driver[1]}), driver arrived at your place!"
            end
            #beri rating :)
            x = @@rated_driver.select{
                |i| i[0] == temp_lokasi_driver
            }[0]
            puts "\n\n\n"
            rating = ask("Beri Rating Untuk Driver #{x[1]} (1 - 5)").to_i
            @@rated_driver[@@rated_driver.index(x)][2] += rating
        end
        his = ask("Wanna View History:(Ya/Tidak)")
        if his == "Ya"
            w = History()
            print w
        end
        File.open("Driver.txt", "w"){
            |file| 
            file.puts("\t\tNama Driver\tRating")
            for i in @@rated_driver
                file.puts("\t\t#{i[1]}\t\t#{i[2]}")
            end
        }
    end

    def self.detail_order
        @@detail_order
    end
end

def History()
    detail = GoEat.detail_order
   # puts @@detail_order
    puts "-------------------------HISTORY-----------------------"
    puts "\t\tNama Toko: #{detail[0][0]}"
    puts "\t\tDetail Pemesanan"
    detail[0][1].each{
        |i,j| puts "\t\t#{i} #{j}"
    }
    puts "\t\tTotal Harga: #{detail[0][2]}"
end

GoEat.start